function check_is_cholesky_decomposition!(db::SQLite.DB, origin_id, id, preprocess_path, preprocess_key, extension_alg, solving_time)
    is_cholesky = -1
    if ismissing(preprocess_path) || preprocess_path == ""
        is_cholesky = 0
    else
        option = TOML.parsefile(preprocess_path)
        if !haskey(option, preprocess_key)
            is_cholesky = 0
        else
            option = option[preprocess_key]
            is_cholesky = (option["nb_edges_to_add"] == 0 && extension_alg == "cholesky") ? 1 : 0
        end
    end
    query = "UPDATE decompositions SET is_cholesky = $is_cholesky WHERE id = $id"
    execute_query(db, query)
    if !ismissing(solving_time)
        query = "UPDATE instances SET cholesky_solving_time = $solving_time WHERE id = $origin_id"
    end
end

function check_is_cholesky_decompositions!(db::SQLite.DB; subset=nothing, recompute=false)
    println("Check is_cholesky")
    println("subset\n$subset\nend subset")
    query = "SELECT origin_id, id, preprocess_path, preprocess_key, extension_alg, solving_time FROM decompositions WHERE 1 = 1"
    if !isnothing(subset)
        query *= " AND id IN ($(join(subset, ',')))"
    end
    if !recompute
        query *= " AND is_cholesky IS NULL "
    end
    results = DBInterface.execute(db, query) |> DataFrame
    check_is_cholesky_decomposition_function!(row) = check_is_cholesky_decomposition!(db, row[:origin_id], row[:id], row[:preprocess_path], row[:preprocess_key], row[:extension_alg], row[:solving_time])
    check_is_cholesky_decomposition_function!.(eachrow(results))
end
