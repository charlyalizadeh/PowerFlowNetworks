function delete_duplicate!(db::SQLite.DB, base_id, graph::AbstractGraph, id, graph_path)
    print("Comparing $base_id and $id")
    other_graph = load_graph(graph_path)
    if graph == other_graph
        println(": $id deleted")
        query = "DELETE FROM decompositions WHERE id = $id"
        execute_query(db, query; wait_until_executed=true)
    end
    println()
end

function delete_duplicate_dfrow!(db::SQLite.DB, id, origin_name::AbstractString, origin_scenario, graph_path)
    println("Checking duplicate: ($origin_name $origin_scenario)")
    query = "SELECT id, graph_path FROM decompositions WHERE origin_name='$origin_name' AND origin_scenario=$origin_scenario AND id > $id"
    results = DBInterface.execute(db, query) |> DataFrame
    graph = load_graph(graph_path)
    delete_duplicate_function!(row) = delete_duplicate!(db, id, graph, row[:id], row[:graph_path])
    delete_duplicate_function!.(eachrow(results[!, [:id, :graph_path]]))
end


function delete_duplicates!(db::SQLite.DB; subset=nothing, kwargs...)
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
