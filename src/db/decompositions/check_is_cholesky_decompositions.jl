function check_is_cholesky_decomposition!(db::SQLite.DB, id, preprocess_path, preprocess_key, extension_alg)
    option = TOML.parsefile(preprocess_path)[preprocess_key]
    is_cholesky = (option["nb_edges_to_add"] == 0 && extension_alg == "cholesky") ? 1 : 0
    query = "UPDATE decompositions SET is_cholesky = $is_cholesky WHERE id = $id"
    execute_query(db, query)
end

function check_is_cholesky_decompositions!(db::SQLite.DB; subset=nothing)
    println("Check is_cholesky")
    println("subset\n$subset\nend subset")
    query = "SELECT id, preprocess_path, preprocess_key, extension_alg FROM decompositions"
    if !isnothing(subset)
        query *= " AND id IN ($(join(subset, ',')))"
    end
    results = DBInterface.execute(db, query) |> DataFrame
    check_is_cholesky_decomposition_function!(row) = check_is_cholesky_decomposition!(db, row[:id], row[:preprocess_path], row[:preprocess_key], row[:extension_alg])
    check_is_cholesky_decomposition_function!.(eachrow(results))
end
