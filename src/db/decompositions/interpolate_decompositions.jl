function interpolate_decomposition!(db::SQLite.DB, how, id, name, scenario, graph_path, g_array, solving_times, rng=MersenneTwister(42))
    println("Interpolating decompositions from ($name, $scenario). Size = $(length(g_array))")
    
    # Interpolate
    g3 = interpolate_graph(g_array; how=how)

    # Extract features
    #clique = maximal_cliques(g3)
    #cliquetree, nb_lc = get_cliquetree_array(clique)
    features = get_features_graph(g3)

    # Save graph
    graphs_path = dirname(graph_path)
    uuid = uuid1(rng)
    graph_path = joinpath(graphs_path, "$(name)_$(scenario)_$(uuid)_graph.lgz")
    serialize_graph(graph_path, g3)

    # Other columns
    date = Dates.now()

    features["solving_time"] = minimum(solving_times)
    features = Dict(Symbol(k) => v for (k, v) in features)
    insert_decomposition!(db, id, uuid, name, scenario, "interpolate:$(how)", "", "", date, "", "", graph_path; wait_until_executed=true, features...)
end

function interpolate_decomposition_dfrow!(db::SQLite.DB, how, nb_per_interpolation, id, origin_id, origin_name, origin_scenario, graph_path, solving_time)
    println("Interpolating: ($origin_name $origin_scenario)")
    query = "SELECT id, graph_path, solving_time FROM decompositions WHERE origin_name='$origin_name' AND origin_scenario=$origin_scenario AND id > $id AND solving_time IS NOT NULL"
    results = execute_query(db, query; return_results=true)
    dict_graph_time = [(load_graph(row[:graph_path]), row[:solving_time]) for row in eachrow(results)]
    graph = load_graph(graph_path)
    for c in combinations(dict_graph_time, nb_per_interpolation - 1)
        (g, s) = c[1]
        g_array = [graph, g]
        solving_times = [solving_time, s]
        interpolate_decomposition!(db, how, origin_id, origin_name, origin_scenario, graph_path, g_array, solving_times)
    end
end

function interpolate_decompositions!(db::SQLite.DB; how::AbstractString, nb_per_interpolation=2, subset=nothing, kwargs...)
    println("Interpolating decompositions")
    query = "SELECT * FROM decompositions WHERE solving_time IS NOT NULL AND extension_alg NOT LIKE 'interpolate:%'"
    if !isnothing(subset)
        query *= " AND id IN ($(join(subset, ',')))"
    end
    results = DBInterface.execute(db, query) |> DataFrame
    println("Interpolate config: how=$how, nb_per_interpolation=$nb_per_interpolation")
    println("subset\n$subset\nend subset")
    interpolate_function(row) = interpolate_decomposition_dfrow!(db, how, nb_per_interpolation, row[:id], row[:origin_id], row[:origin_name], row[:origin_scenario], row[:graph_path], row[:solving_time])
    interpolate_function.(eachrow(results))
end
