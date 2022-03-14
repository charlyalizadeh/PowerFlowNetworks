function check_chordality_decomposition(db::SQLite.DB, id, name, scenario, graph_path)
    g = loadgraph(graph_path)
    if !ischordal(g)
        println("Decomposition $name scenario $scenario id $id not chordal.")
    end
end

function check_chordality_decomposition_dfrow(db::SQLite.DB, row) 
    check_chordality_decomposition(db, row[:id], row[:origin_name], row[:origin_scenario], row[:graph_path])
end

function check_chordality_decompositions(db::SQLite.DB; min_nv=typemin(Int), max_nv=typemax(Int))
    query = "SELECT id, origin_name, origin_scenario, graph_path FROM decompositions WHERE nb_vertex >= $min_nv AND nb_vertex <= $max_nv"
    results = DBInterface.execute(db, query) |> DataFrame
    check_func(row) = check_chordality_decomposition_dfrow(db, row)
    check_func.(eachrow(results[!, [:id, :origin_name, :origin_scenario, :graph_path]]))
end
