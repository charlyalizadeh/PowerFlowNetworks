function generate_decomposition!(db::SQLite.DB, id::Int, name::AbstractString, scenario::Union{Int, AbstractString},
                                 cliques_path::AbstractString, cliquetrees_path::AbstractString, graphs_path::AbstractString,
                                 extension_alg::AbstractString, option::AbstractDict,
                                 preprocess_path::AbstractString, preprocess_key::AbstractString, graph_path::AbstractString;
                                 seed, rng, chordal_extension_kwargs...)
    println("Generating decomposition: ($name $scenario) ($extension_alg)")
    g = load_graph(graph_path)

    # Preprocessing
    option = deepcopy(option)
    nb_edges_to_add = option[:nb_edges_to_add]
    option[:nb_edges_to_add] != 0 && add_edges!(g, pop!(option, :nb_edges_to_add), pop!(option, :how); option...)

    # Chordal extension
    chordal_g, data = chordal_extension(g, extension_alg; chordal_extension_kwargs...)

    # Features extraction
    features = get_features_graph(chordal_g)
    features["nb_added_edge_dec"] = ne(chordal_g) - ne(g)
    clique = maximal_cliques(chordal_g)
    cliquetree, nb_lc = get_cliquetree_array(clique)
    merge!(features, get_clique_features(clique))

    # Check if the decomposition is the "cholesky decomposition" (i.e. no edges added in preprocessing + extension algorithm = cholesky)
    features["is_cholesky"] = (nb_edges_to_add == 0 && extension_alg == "cholesky") ? 1 : 0

    # Save cliques and cliquetree
    uuid = uuid1(rng)
    clique_path = joinpath(cliques_path, "$(name)_$(scenario)_$(uuid)_clique.csv")
    cliquetree_path = joinpath(cliquetrees_path, "$(name)_$(scenario)_$(uuid)_cliquetree.csv")
    graph_path_dec = joinpath(graphs_path, "$(name)_$(scenario)_$(uuid)_graphs.lgz")
    save_clique(clique, clique_path) 
    # Case when the graph is complete (1 clique)
    if isempty(cliquetree)
        cliquetree = [[1, 1]]
    end
    save_cliquetree(cliquetree, cliquetree_path)
    serialize_graph(graph_path_dec, chordal_g)

    # Other columns
    date = Dates.now()

    features = Dict(Symbol(k) => v for (k, v) in features)
    insert_decomposition!(db, id, uuid, name, scenario, extension_alg, preprocess_path, preprocess_key, date, clique_path, cliquetree_path, graph_path_dec; features...)
end

function generate_decompositions!(db::SQLite.DB;
                                  cliques_path, cliquetrees_path, graphs_path,
                                  extension_alg::AbstractString, preprocess_path::AbstractString, preprocess_key::AbstractString,
                                  min_nv=typemin(Int), max_nv=typemax(Int), subset=nothing,
                                  seed=MersenneTwister(42), rng=MersenneTwister(42),
                                  chordal_extension_kwargs::AbstractDict=Dict(),
                                  kwargs...)
    println("Generate decompositions config: extension_alg=$extension_alg, preprocess_path=$preprocess_path, min_nv=$min_nv, max_nv=$max_nv, seed=$seed, rng=$rng")
    println("subset\n$subset\nend subset")
    !isdir(cliques_path) && mkpath(cliques_path)
    !isdir(cliquetrees_path) && mkpath(cliquetrees_path)
    query = "SELECT id, name, scenario, graph_path FROM instances WHERE nbus >= $min_nv AND nbus <= $max_nv"
    if !isnothing(subset)
        query *= " AND id IN ($(join(subset, ',')))"
    end
    option = TOML.parsefile(preprocess_path)[preprocess_key]
    option = Dict(Symbol(k) => v for (k, v) in option)
    results = DBInterface.execute(db, query) |> DataFrame
    generate_function!(row) = generate_decomposition!(db, row[:id], row[:name], row[:scenario], cliques_path, cliquetrees_path, graphs_path,
                                                      extension_alg, option, preprocess_path, preprocess_key, row[:graph_path];
                                                      seed=seed, rng=rng, chordal_extension_kwargs...)
    generate_function!.(eachrow(results))
end
