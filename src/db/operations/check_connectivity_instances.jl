function check_connectivity_instance(db::SQLite.DB, name, scenario, graph_path)
    g = loadgraph(graph_path)
    if !is_connected(g)
        println("Instance $name $scenario is not connected. Number of components: $(size(connected_components(g), 1))")
    end
end

function check_connectivity_instance_dfrow(db::SQLite.DB, row) 
    check_connectivity_instance(db, row[:name], row[:scenario], row[:graph_path])
end

function check_connectivity_instances(db::SQLite.DB; min_nv=typemin(Int), max_nv=typemax(Int))
    query = "SELECT name, scenario, graph_path FROM instances WHERE nbus >= $min_nv AND nbus <= $max_nv"
    results = DBInterface.execute(db, query) |> DataFrame
    check_func(row) = check_connectivity_instance_dfrow(db, row)
    check_func.(eachrow(results[!, [:name, :scenario, :graph_path]]))
end
