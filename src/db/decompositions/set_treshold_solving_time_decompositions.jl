function set_treshold_solving_time_decomposition!(db::SQLite.DB, origin_name, origin_scenario, id, solving_time, cholesky_times, treshold)
    treshold = treshold * cholesky_times["$(origin_name)_$(origin_scenario)"]
    if solving_time > treshold
        solving_time = treshold
        query = "UPDATE decompositions SET solving_time = $solving_time WHERE id = $id"
        execute_query(db, query)
    end
end

function set_treshold_solving_time_decompositions!(db::SQLite.DB; subset=nothing, treshold=2)
    println("Setting treshold for solving time")
    println("subset\n$subset\nend subset")
    query = "SELECT origin_name, origin_scenario, id, solving_time FROM decompositions WHERE solving_time IS NOT NULL AND is_cholesky = 0 "
    if !isnothing(subset)
        query *= " AND id IN ($(join(subset, ',')))"
    end
    results = DBInterface.execute(db, query) |> DataFrame
    cholesky_times = get_cholesky_times(db)
    set_treshold_solving_time_decomposition_function!(row) = set_treshold_solving_time_decomposition!(db, row[:origin_name], row[:origin_scenario], row[:id], row[:solving_time], cholesky_times, treshold)
    set_treshold_solving_time_decomposition_function!.(eachrow(results))
end
