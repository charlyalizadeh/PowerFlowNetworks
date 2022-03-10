# Save features
function save_features_instance!(db::SQLite.DB, name, scenario, source_type, source_path;
                                 serialize_network, serialize_path)
    println("Saving features: $name scenario $scenario")
    network = PowerFlowNetwork(source_path, source_type)
    merge_duplicate_branch!(network)
    features = get_features_instance(network)
    query = "UPDATE instances SET "
    for (feature_name, feature_value) in features
        if feature_value == Inf
            query *= "$feature_name = '+Infinity', "
        elseif feature_value == -Inf
            query *= "$feature_name = '-Infinity', "
        else
            query *= "$feature_name = $feature_value, "
        end
    end

    # Serialize the `PowerFlowNetwork` object
    if serialize_network
        serialize_path = joinpath(serialize_path, "$(name)_$(scenario)")
        serialize(serialize_path, network)
        query *= "pfn_path = '$serialize_path', "
    end

    query = query[begin:end - 2]
    query *= " WHERE name = '$name' AND scenario = $scenario"
    DBInterface.execute(db, query)
end
function save_features_instance_dfrow!(db::SQLite.DB, row; serialize_network, serialize_path) 
    save_features_instance!(db, row[:name], row[:scenario], row[:source_type], row[:source_path];
                            serialize_network=serialize_network, serialize_path=serialize_path)
end
function save_features_instances!(db::SQLite.DB; serialize_network, serialize_path,
                                  min_nv=typemin(Int), max_nv=typemax(Int), recompute=false)
    serialize_network && mkpath(serialize_path)
    query = "SELECT name, scenario, source_type, source_path FROM instances WHERE nbus >= $min_nv AND nbus <= $max_nv"
    if !recompute
        query *= " AND nb_edge IS NULL"
    end
    results = DBInterface.execute(db, query) |> DataFrame
    save_func!(row) = save_features_instance_dfrow!(db, row;
                                                    serialize_network=serialize_network, serialize_path=serialize_path)
    save_func!.(eachrow(results[!, [:name, :scenario, :source_type, :source_path]]))
end

# Save basic features
function save_basic_features_instance!(db::SQLite.DB, name, scenario, source_type, source_path)
    println("Saving features: $name scenario $scenario")
    _nbus = nbus(source_path, source_type)
    _nbranch_unique = nbranch(source_path, source_type; distinct_pair=true)
    _nbranch = nbranch(source_path, source_type)
    _ngen = ngen(source_path, source_type)
    query = """
    UPDATE instances
    SET nbus = $_nbus, nbranch_unique = $_nbranch_unique, nbranch = $_nbranch, ngen = $_ngen
    WHERE name = '$name' AND scenario = $scenario;
    """
    DBInterface.execute(db, query)
end
function save_basic_features_instance_dfrow!(db::SQLite.DB, row)
    save_basic_features_instance!(db, row[:name], row[:scenario], row[:source_type], row[:source_path])
end
function save_basic_features_instances!(db::SQLite.DB; recompute=false)
    query = "SELECT name, scenario, source_type, source_path FROM instances"
    if !recompute
        query *= " WHERE nbus IS NULL OR nbranch_unique IS NULL OR nbranch IS NULL OR ngen IS NULL"
    end
    results = DBInterface.execute(db, query) |> DataFrame
    save_func!(row) = save_basic_features_instance_dfrow!(db, row)
    save_func!.(eachrow(results[!, [:name, :scenario, :source_type, :source_path]]))
end

# Save single features
function save_single_features_instance!(db::SQLite.DB, feature_names, use_network, name, scenario, source_type, source_path, pfn_path)
    println("Saving features $(feature_names): $name scenario $scenario")
    network = nothing
    if use_network
        network = ismissing(pfn_path) ? PowerFlowNetwork(source_path, source_type) : deserialize(pfn_path)
    end
    feature_values = Dict()
    query = "UPDATE instances SET "
    for feature_name in feature_names
        feature_info = _feature_info_dict[feature_name]
        if feature_info[1] == :graph
            g = SimpleGraph(network)
            feature_value = get_single_feature_graph(feature_name, g)
        elseif feature_info[1] == :network
            feature_value = get_single_feature_network(feature_name, network)
        elseif feature_info[1] == :source_path
            feature_value = get_single_feature_source_path(feature_name, source_path)
        end
        if feature_info[2]
            query *= """
            $(feature_name)_max = $(feature_value[1]),
            $(feature_name)_min = $(feature_value[2]),
            $(feature_name)_mean = $(feature_value[3]),
            """
        else
            query *= "$(feature_name) = $(feature_value),"
        end
    end
    query = query[begin:end - 1] * " WHERE name = '$name' AND scenario = $scenario"
    DBInterface.execute(db, query)
end
function save_single_features_instance_dfrow!(db::SQLite.DB, feature_names, use_network, row)
    save_single_features_instance!(db, feature_names, use_network, row[:name], row[:scenario], row[:source_type], row[:source_path], row[:pfn_path])
end
function save_single_features_instances!(db::SQLite.DB, feature_names;
                                         min_nv=typemin(Int), max_nv=typemax(Int), recompute=false)
    query = "SELECT name, scenario, source_type, source_path, pfn_path FROM instances WHERE nbus >= $min_nv AND nbus <= $max_nv"
    if !recompute
        for feature_name in feature_names
            query *= " AND $feature_name IS NULL"
        end
    end
    use_network = any([_feature_info_dict[f][1] in (:graph, :network) for f in feature_names])
    results = DBInterface.execute(db, query) |> DataFrame
    save_func!(row) = save_single_features_instance_dfrow!(db, feature_names, use_network, row)
    save_func!.(eachrow(results[!, [:name, :scenario, :source_type, :source_path, :pfn_path]]))
end

# Serialize
function serialize_instance!(db::SQLite.DB, serialize_path, name, scenario, source_type, source_path)
    println("Serializing: $name scenario $scenario")
    pfn_path = abspath(joinpath(serialize_path, "$(name)_$(scenario)_network.bin"))
    graph_path = abspath(joinpath(serialize_path, "$(name)_$(scenario)_graph.lgz"))
    network = PowerFlowNetwork(source_path, source_type)
    g = SimpleGraph(network)
    serialize(pfn_path, network)
    savegraph(graph_path, g)
    query = "UPDATE instances SET pfn_path = '$pfn_path', graph_path = '$graph_path' WHERE name = '$name' AND scenario = $scenario"
    DBInterface.execute(db, query)
end
function serialize_instance_dfrow!(db::SQLite.DB, serialize_path, row)
    serialize_instance!(db, serialize_path, row[:name], row[:scenario], row[:source_type], row[:source_path])
end
function serialize_instances!(db::SQLite.DB, serialize_path;
                              min_nv=typemin(Int), max_nv=typemax(Int), recompute=false)
    !isdir(serialize_path) && mkpath(serialize_path)
    query = "SELECT name, scenario, source_type, source_path FROM instances WHERE nbus >= $min_nv AND nbus <= $max_nv"
    if !recompute
        query *= " AND pfn_path IS NULL"
    end
    results = DBInterface.execute(db, query) |> DataFrame
    serialize_func!(row) = serialize_instance_dfrow!(db, serialize_path, row)
    serialize_func!.(eachrow(results[!, [:name, :scenario, :source_type, :source_path]]))
end

# Generate decompositions
_save_cliques(cliques::Vector{Vector{Int}}, path::AbstractString) = writedlm(path, cliques)
_save_cliquetree(cliquetree::Vector{Vector{Int}}, path::AbstractString) = writedlm(path, cliquetree)

function generate_decomposition!(db::SQLite.DB, cliques_path::AbstractString, cliquetrees_path::AbstractString,
                                 extension_alg::AbstractString, option::AbstractDict, preprocess_path::AbstractString,
                                 name::AbstractString, scenario::Union{Int, AbstractString}, graph_path::AbstractString;
                                 seed, rng, kwargs...)
    println("Generating decomposition: $name scenario $scenario. ($extension_alg)")
    g = loadgraph(graph_path)

    # Preprocessing
    option = deepcopy(option)
    option[:nb_edges_to_add] != 0 && add_edges!(g, pop!(option, :nb_edges_to_add), pop!(option, :how); option...)

    # Chordal extension
    chordal_g, data = chordal_extension(g, extension_alg; kwargs...)

    # Features extraction
    features = get_features_graph(chordal_g)
    features["nb_added_edge_dec"] = ne(chordal_g) - ne(g)
    cliques = maximal_cliques(chordal_g)
    cliquetree, nb_lc = get_cliquetree_array(cliques)
    merge!(features, get_cliques_features(cliques))

    # Save cliques and cliquetree
    uuid = uuid1(rng)
    clique_path = joinpath(cliques_path, "$(name)_$(scenario)_$(uuid)_cliques.csv")
    cliquetree_path = joinpath(cliquetrees_path, "$(name)_$(scenario)_$(uuid)_cliquetree.csv")
    _save_cliques(cliques, cliquetree_path) 
    _save_cliquetree(cliquetree, cliquetree_path)

    # Other columns
    date = Dates.now()

    features = Dict(Symbol(k) => v for (k, v) in features)
    insert_decomposition!(db, uuid, name, scenario, extension_alg, preprocess_path, date, clique_path, cliquetree_path; features...)
end

function generate_decomposition_dfrow!(db::SQLite.DB, cliques_path::AbstractString, cliquetrees_path::AbstractString,
                                       extension_alg::AbstractString, option::AbstractDict, preprocess_path::AbstractString,
                                       row; seed, rng, kwargs...)
    generate_decomposition!(db, cliques_path, cliquetrees_path, extension_alg, option, preprocess_path,
                            row[:name], row[:scenario], row[:graph_path];
                            seed=seed, rng=rng, kwargs...)
end

function generate_decompositions!(db::SQLite.DB,
                                  cliques_path, cliquetrees_path,
                                  extension_alg::AbstractString, preprocess_path::AbstractString;
                                  seed=MersenneTwister(42), rng=MersenneTwister(42),
                                  min_nv=typemin(Int), max_nv=typemax(Int), kwargs...)
    !isdir(cliques_path) && mkpath(cliques_path)
    !isdir(cliquetrees_path) && mkpath(cliquetrees_path)
    query = "SELECT name, scenario, graph_path FROM instances WHERE nbus >= $min_nv AND nbus <= $max_nv"
    option = JSON.parse(read(open(preprocess_path, "r"), String))
    option = Dict(Symbol(k) => v for (k, v) in option)
    results = DBInterface.execute(db, query) |> DataFrame
    generate_func!(row) = generate_decomposition_dfrow!(db, cliques_path, cliquetrees_path,
                                                        extension_alg, option, preprocess_path,
                                                        row; seed=seed, rng=rng, kwargs...)
    generate_func!.(eachrow(results[!, [:name, :scenario, :graph_path]]))
end
