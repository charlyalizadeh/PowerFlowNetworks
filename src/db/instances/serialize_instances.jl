function serialize_instance!(db::SQLite.DB, networks_path, graphs_path, name, scenario, source_type, source_path)
    println("Serializing instance network and graph: ($name, $scenario)")
    network_path = abspath(joinpath(networks_path, "$(name)_$(scenario)_network.bin"))
    graph_path = abspath(joinpath(graphs_path, "$(name)_$(scenario)_graph.lgz"))
    network = PowerFlowNetwork(source_path, source_type)
    replace_inf_by!(network)
    if get_cost_type(network) == "piecewise linear"
        convert_gencost!(network, "polynomial")
    end
    g = SimpleGraph(network)
    serialize_network(network_path, network)
    serialize_graph(graph_path, g)
    query = "UPDATE instances SET network_path = '$network_path', graph_path = '$graph_path' WHERE name = '$name' AND scenario = $scenario"
    execute_query(db, query)
end

function serialize_instances!(db::SQLite.DB;
                              networks_path, graphs_path,
                              min_nv=typemin(Int), max_nv=typemax(Int), recompute=false,
                              subset=nothing, kwargs...)
    !isdir(networks_path) && mkpath(networks_path)
    !isdir(graphs_path) && mkpath(graphs_path)
    query = "SELECT name, scenario, source_type, source_path FROM instances WHERE nbus >= $min_nv AND nbus <= $max_nv"
    if !recompute
        query *= " AND (network_path IS NULL OR graph_path IS NULL)"
    end
    if !isnothing(subset)
        query *= " AND id IN ($(join(subset, ',')))"
    end
    println("Serialize instance network and graph config: min_nv=$min_nv, max_nv=$max_nv, recompute=$recompute")
    println("subset\n$subset\nend subset")
    results = DBInterface.execute(db, query) |> DataFrame
    serialize_function!(row) = serialize_instance!(db, networks_path, graphs_path, row[:name], row[:scenario], row[:source_type], row[:source_path])
    serialize_function!.(eachrow(results))
end
