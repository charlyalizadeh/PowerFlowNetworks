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
    insert_decomposition!(db, id, uuid, name, scenario, "combine:$(extension_alg)", "", "", date, clique_path, cliquetree_path, graph_path; wait_until_executed=true, features...)

    # Insert in merge table
    out_id = execute_query(db, "SELECT id FROM decompositions WHERE uuid = '$uuid'"; return_results=true)
    out_id = out_id[1, :id]
    insert_combination!(db, id_1, id_2, out_id, how, extension_alg)
end

is_not_valid_dec(name, solving_time, cholesky_times, percent_max) = !haskey(cholesky_times, name) || solving_time > percent_max * cholesky_times[name]

function filter_decompositions!(decompositions, cholesky_times, percent_max=0.5)
    to_delete = []
    for row in eachrow(decompositions)
        name_1 = "$(row[:origin_name])_$(row[:origin_scenario])"
        name_2 = "$(row[:origin_name_1])_$(row[:origin_scenario_1])"
        solving_time_1 = row[:solving_time]
        solving_time_2 = row[:solving_time_1]
        id = getfield(row, :dfrow)
        if is_not_valid_dec(name_1, solving_time_1, cholesky_times, percent_max) || is_not_valid_dec(name_2, solving_time_2, cholesky_times, percent_max)
            push!(to_delete, id)
        end
    end
    deleteat!(decompositions, to_delete)
end

function combine_decompositions!(db::SQLite.DB; how::AbstractString, extension_alg::AbstractString,
                                 min_nv=typemin(Int), max_nv=typemax(Int), subset=nothing, exclude=["combine"], percent_max=0.5, rng=MersenneTwister(42), kwargs...)
    query = """
    SELECT d1.origin_id, d1.id, d1.origin_name, d1.origin_scenario, d1.graph_path, d1.clique_path, d1.cliquetree_path, d1.nb_added_edge_dec, d1.extension_alg, d1.solving_time,
           d2.id, d2.origin_name, d2.origin_scenario, d2.graph_path, d2.extension_alg, d2.solving_time
    FROM decompositions AS d1 CROSS JOIN decompositions AS d2
    WHERE d1.origin_name = d2.origin_name AND d1.origin_scenario = d2.origin_scenario AND d1.id > d2.id  AND d1.solving_time IS NOT NULL AND d2.solving_time IS NOT NULL
    """
    if !isnothing(subset)
        query *= " AND d1.origin_id IN ($(join(subset, ',')))"
    end
    for e in exclude
        query *= " AND d1.extension_alg NOT LIKE '$e%' AND d2.extension_alg NOT LIKE '$e%'"
    end
    cholesky_times = get_cholesky_times(db)
    results = DBInterface.execute(db, query) |> DataFrame
    filter_decompositions!(results, cholesky_times, percent_max)
    println("Combine config: how=$how, extension_alg=$extension_alg, min_nv=$min_nv, max_nv=$max_nv, exlucde=$exclude, rng=$rng")
    println("subset\n$subset\nend subset")
    combine_function!(row) = combine_decomposition!(db, row[:origin_id], row[:origin_name], row[:origin_scenario],
                                                    row[:clique_path], row[:cliquetree_path], row[:nb_added_edge_dec],
                                                    row[:id], row[:graph_path],
                                                    row[:id_1], row[:graph_path_1];
                                                    how=how, extension_alg=extension_alg, rng=rng)
    combine_function!.(eachrow(results))
end
