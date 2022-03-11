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
