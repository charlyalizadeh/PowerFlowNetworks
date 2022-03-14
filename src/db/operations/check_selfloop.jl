function check_selfloop(db::SQLite.DB, id, name, scenario, graph_path)
    g = loadgraph(graph_path)
    if has_self_loops(g)
        println("$name scenario $scenario id $id has some self loops.")
    end
end

function check_selfloop_dfrow(db::SQLite.DB, row) 
    check_selfloop(db, row[:id], row[:name], row[:scenario], row[:graph_path])
end

function check_selfloops(db::SQLite.DB; min_nv=typemin(Int), max_nv=typemax(Int), table="instances")
    results = nothing
    if table == "instances"
        query = "SELECT name, scenario, graph_path FROM instances WHERE nb_vertex >= $min_nv AND nb_vertex <= $max_nv"
        results = DBInterface.execute(db, query) |> DataFrame
        results[!, :id] = ["" for i in 1:nrow(results)]
    elseif table == "decompositions"
        query = "SELECT id, origin_name, origin_scenario, graph_path FROM decompositions WHERE nb_vertex >= $min_nv AND nb_vertex <= $max_nv"
        results = DBInterface.execute(db, query) |> DataFrame
        rename!(results, :origin_name => :name, :origin_scenario => :scenario)
    end
    check_func(row) = check_selfloop_dfrow(db, row)
    check_func.(eachrow(results[!, [:id, :name, :scenario, :graph_path]]))
end
