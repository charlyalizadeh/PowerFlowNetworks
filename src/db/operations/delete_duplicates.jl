function _delete_duplicate!(db::SQLite.DB, base_id, graph::AbstractGraph, id, graph_path)
    println("Comparing $base_id and $id")
    other_graph = loadgraph(graph_path)
    if graph == other_graph
        println("ICI")
        query = "DELETE FROM decompositions WHERE id = $id"
        execute_set_immediate(db, query)
    end
end


function delete_duplicate_dfrow!(db::SQLite.DB, id, origin_name::AbstractString, origin_scenario, graph_path)
    println("Delete duplicate: ($origin_name $origin_scenario)")
    query = "SELECT id, graph_path FROM decompositions WHERE origin_name='$origin_name' AND origin_scenario=$origin_scenario AND id > $id"
    results = DBInterface.execute(db, query) |> DataFrame
    graph = loadgraph(graph_path)
    delete_duplicate_function!(row) = _delete_duplicate!(db, id, graph, row[:id], row[:graph_path])
    delete_duplicate_function!.(eachrow(results[!, [:id, :graph_path]]))
end



function delete_duplicates!(db::SQLite.DB; subset=nothing)
    println("Deleting duplicates")
    println("subset\n$subset\nend subset")
    query = "SELECT id, origin_name, origin_scenario, graph_path FROM decompositions"
    if !isnothing(subset)
        query *= " WHERE origin_id IN ($(join(subset, ',')))"
    end
    println(query)
    results = DBInterface.execute(db, query) |> DataFrame
    delete_duplicate_function!(row) = delete_duplicate_dfrow!(db, row[:id], row[:origin_name], row[:origin_scenario], row[:graph_path])
    delete_duplicate_function!.(eachrow(results[!, [:id, :origin_name, :origin_scenario, :graph_path]]))
end
