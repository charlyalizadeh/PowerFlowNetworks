_save_cliques(cliques::Vector{Vector{Int}}, path::AbstractString) = writedlm(path, cliques)
_save_cliquetree(cliquetree::Vector{Vector{Int}}, path::AbstractString) = writedlm(path, cliquetree)

function generate_decomposition!(db::SQLite.DB, name::AbstractString, scenario::Union{Int, AbstractString},
                                 cliques_path::AbstractString, cliquetrees_path::AbstractString,
                                 extension_alg::AbstractString, option::AbstractDict,
                                 preprocess_path::AbstractString, graph_path::AbstractString;
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
    _save_cliques(cliques, clique_path) 
    _save_cliquetree(cliquetree, cliquetree_path)

    # Other columns
    date = Dates.now()

    features = Dict(Symbol(k) => v for (k, v) in features)
    insert_decomposition!(db, uuid, name, scenario, extension_alg, preprocess_path, date, clique_path, cliquetree_path; features...)
end

function generate_decomposition_dfrow!(db::SQLite.DB, row, cliques_path::AbstractString, cliquetrees_path::AbstractString,
                                       extension_alg::AbstractString, option::AbstractDict, preprocess_path::AbstractString;
                                       seed, rng, kwargs...)
    generate_decomposition!(db, row[:name], row[:scenario], cliques_path, cliquetrees_path,
                            extension_alg, option,
                            preprocess_path, row[:graph_path];
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
    generate_func!(row) = generate_decomposition_dfrow!(db, row, cliques_path, cliquetrees_path,
                                                        extension_alg, option, preprocess_path;
                                                        seed=seed, rng=rng, kwargs...)
    generate_func!.(eachrow(results[!, [:name, :scenario, :graph_path]]))
end
