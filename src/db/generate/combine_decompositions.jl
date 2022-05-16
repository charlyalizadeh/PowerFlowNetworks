function combine_decomposition!(db::SQLite.DB, id::Int, name::AbstractString, scenario::Union{Int, AbstractString},
                                clique_path::AbstractString, cliquetree_path::AbstractString, nb_added_edge_dec::Int,
                                id_1::Int, graph_path_1::AbstractString,
                                id_2::Int, graph_path_2::AbstractString;
                                how::AbstractString, extension_alg::AbstractString, rng)
    println("Combining decompositions ($name, $scenario) (in1=$id_1, in2=$id_2)")
    
    # Retrieve the graphs
    g1 = load_graph(graph_path_1)
    g2 = load_graph(graph_path_2)
    
    # Combine
    g3 = combine_graph(g1, g2; how=how, extension_alg=extension_alg)

    # Extract features
    clique = maximal_cliques(g3)
    cliquetree, nb_lc = get_cliquetree_array(clique)
    features = get_features_graph(g3)
    features["nb_lc"] = nb_lc
    features["nb_added_edge_dec"] = nb_added_edge_dec + (ne(g3) - ne(g1))
    merge!(features, get_clique_features(clique))

    # Save cliques, cliquetree and graph
    cliques_path = dirname(clique_path)
    cliquetrees_path = dirname(cliquetree_path)
    graphs_path = dirname(graph_path_1)
    uuid = uuid1(rng)
    clique_path = joinpath(cliques_path, "$(name)_$(scenario)_$(uuid)_clique.csv")
    cliquetree_path = joinpath(cliquetrees_path, "$(name)_$(scenario)_$(uuid)_cliquetree.csv")
    graph_path = joinpath(graphs_path, "$(name)_$(scenario)_$(uuid)_graph.lgz")
    save_clique(clique, clique_path) 
    save_cliquetree(cliquetree, cliquetree_path)
    serialize_graph(graph_path, g3)

    # Other columns
    date = Dates.now()

    features = Dict(Symbol(k) => v for (k, v) in features)
    insert_decomposition!(db, id, uuid, name, scenario, "combine", extension_alg, date, clique_path, cliquetree_path, graph_path; features...)

    # Insert in merge table
    out_id = DBInterface.execute(db, "SELECT id FROM decompositions WHERE uuid = '$uuid'") |> DataFrame
    out_id = out_id[1, :id]
    insert_combination!(db, id_1, id_2, out_id, how, extension_alg)
end

function combine_decompositions!(db::SQLite.DB; how::AbstractString, extension_alg::AbstractString,
                                 min_nv=typemin(Int), max_nv=typemax(Int), subset=nothing, exclude=["combine"], rng=MersenneTwister(42), kwargs...)
    query = """
    SELECT d1.origin_id, d1.id, d1.origin_name, d1.origin_scenario, d1.graph_path, d1.clique_path, d1.cliquetree_path, d1.nb_added_edge_dec, d1.extension_alg,
           d2.id, d2.origin_name, d2.origin_scenario, d2.graph_path, d2.extension_alg
    FROM decompositions AS d1 CROSS JOIN decompositions AS d2
    WHERE d1.origin_name = d2.origin_name AND d1.origin_scenario = d2.origin_scenario AND d1.id > d2.id 
    """
    if !isnothing(subset)
        query *= " AND d1.origin_id IN ($(join(subset, ',')))"
    end
    for e in exclude
        query *= " AND d1.extension_alg <> '$e' AND d2.extension_alg <> '$e'"
    end
    results = DBInterface.execute(db, query) |> DataFrame
    println("Combine config: how=$how, extension_alg=$extension_alg, min_nv=$min_nv, max_nv=$max_nv, exlucde=$exclude, rng=$rng")
    println("subset\n$subset\nend subset")
    combine_function!(row) = combine_decomposition!(db, row[:origin_id], row[:origin_name], row[:origin_scenario],
                                                    row[:clique_path], row[:cliquetree_path], row[:nb_added_edge_dec],
                                                    row[:id], row[:graph_path],
                                                    row[:id_1], row[:graph_path_1];
                                                    how=how, extension_alg=extension_alg, rng=rng)
    combine_function!.(eachrow(results))
end
