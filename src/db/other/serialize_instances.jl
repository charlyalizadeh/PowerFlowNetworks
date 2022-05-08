function serialize_instance!(db::SQLite.DB, serialize_path, graphs_path, name, scenario, source_type, source_path)
    println("Serializing instance network and graph: ($name, $scenario)")
    pfn_path = abspath(joinpath(serialize_path, "$(name)_$(scenario)_network.bin"))
    graph_path = abspath(joinpath(graphs_path, "$(name)_$(scenario)_graph.lgz"))
    network = PowerFlowNetwork(source_path, source_type)
    set_index_gencost!(network)
    g = SimpleGraph(network)
    serialize(pfn_path, network)
    savegraph(graph_path, g)
    query = "UPDATE instances SET pfn_path = '$pfn_path', graph_path = '$graph_path' WHERE name = '$name' AND scenario = $scenario"
    execute_query(db, query)
end

function serialize_instances!(db::SQLite.DB;
                              serialize_path, graphs_path,
                              min_nv=typemin(Int), max_nv=typemax(Int), recompute=false,
                              subset=nothing)
    !isdir(serialize_path) && mkpath(serialize_path)
    !isdir(graphs_path) && mkpath(graphs_path)
    query = "SELECT name, scenario, source_type, source_path FROM instances WHERE nbus >= $min_nv AND nbus <= $max_nv"
    if !recompute
        query *= " AND (pfn_path IS NULL OR graph_path IS NULL)"
    end
    if !isnothing(subset)
        query *= " AND id IN ($(join(subset, ',')))"
    end
    println("Serialize instance network and graph config: min_nv=$min_nv, max_nv=$max_nv, recompute=$recompute")
    println("subset\n$subset\nend subset")
    results = DBInterface.execute(db, query) |> DataFrame
    serialize_function!(row) = serialize_instance!(db, serialize_path, graphs_path, row[:name], row[:scenario], row[:source_type], row[:source_path])
    serialize_function!.(eachrow(results))
end
