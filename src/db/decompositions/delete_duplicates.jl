function delete_duplicate!(db::SQLite.DB, base_uuid, base_id, graph::AbstractGraph, uuid, id, graph_path)
    print("Comparing $base_id and $id")
    other_graph = load_graph(graph_path)
    if graph == other_graph
        println(": $id deleted")
        query = "DELETE FROM decompositions WHERE id = $id"
        execute_query(db, query; wait_until_executed=true)
    else
        query = "INSERT INTO duplicates(uuid1, uuid2) VALUES('$base_uuid', '$uuid')"
        execute_query(db, query)
    end
    println()
end

function delete_duplicate_dfrow!(db::SQLite.DB, uuid, id, origin_name::AbstractString, origin_scenario, graph_path)
    println("Checking duplicate: ($origin_name $origin_scenario)")
    query = """SELECT uuid, id, graph_path FROM decompositions
               WHERE origin_name='$origin_name' AND origin_scenario=$origin_scenario AND id > $id
               AND NOT EXISTS
               (
                   SELECT 1 FROM duplicates
                   WHERE uuid1 = '$uuid' AND uuid2 = decompositions.uuid
               );"""
    results = execute_query(db, query; return_results=true)
    graph = load_graph(graph_path)
    delete_duplicate_function!(row) = delete_duplicate!(db, uuid, id, graph, row[:uuid], row[:id], row[:graph_path])
    delete_duplicate_function!.(eachrow(results[!, [:uuid, :id, :graph_path]]))
end


function delete_duplicates!(db::SQLite.DB; subset=nothing, kwargs...)
    println("Deleting duplicates")
    println("subset\n$subset\nend subset")
    query = "SELECT uuid, id, origin_name, origin_scenario, graph_path FROM decompositions"
    if !isnothing(subset)
        query *= " WHERE origin_id IN ($(join(subset, ',')))"
    end
    results = execute_query(db, query; return_results=true)
    delete_duplicate_function!(row) = delete_duplicate_dfrow!(db, row[:uuid], row[:id], row[:origin_name], row[:origin_scenario], row[:graph_path])
    delete_duplicate_function!.(eachrow(results[!, [:uuid, :id, :origin_name, :origin_scenario, :graph_path]]))
end
