function solve_decomposition!(db::SQLite.DB, id, origin_name, origin_scenario, clique_path, cliquetree_path, is_cholesky, mat_path, ctr_path)
    println("Solving ($origin_name, $origin_scenario, $id)")
    cliques = read_clique(clique_path)
    cliquetree = read_cliquetree(cliquetree_path)
    instance_name = "$(origin_name)_$(origin_scenario)"
    solving_time, nb_iter, solve_log_path, objective, m, nb_lc = "'NaN'", "'NaN'", "", "'NaN'", "'NaN'", "'NaN'"
    try
        solving_time, nb_iter, solve_log_path, objective, m, nb_lc = solve_sdp(instance_name, cliques, cliquetree, ctr_path, mat_path)
    catch e
        println("($origin_name, $origin_scenario, $id) could not be solved.")
        flush(stderr)
        flush(stdout)
    end
    query = """
    UPDATE decompositions SET solving_time=$solving_time, nb_iter=$nb_iter, solve_log_path='$solve_log_path', objective=$objective, m=$m, nb_lc=$nb_lc
    WHERE id = $id
    """
    execute_query(db, query)
    if is_cholesky == 1
        query = "UPDATE instances SET cholesky_solving_time=$solving_time WHERE name='$origin_name' AND scenario=$origin_scenario"
        execute_query(db, query)
    end
end

function solve_decomposition_dfrow!(db::SQLite.DB, id, origin_id, origin_name, origin_scenario, clique_path, cliquetree_path, is_cholesky, mat_paths, ctr_paths)
    if !haskey(mat_paths, origin_id) || !haskey(ctr_paths, origin_id) || ismissing(ctr_paths[origin_id]) || ismissing(mat_paths[origin_id])
        println("No matctr files registered in the database for ($origin_name, $origin_scenario).")
    else
        solve_decomposition!(db, id, origin_name, origin_scenario, clique_path, cliquetree_path, is_cholesky, mat_paths[origin_id], ctr_paths[origin_id])
    end
end

function solve_decompositions!(db::SQLite.DB; subset=nothing, recompute=false, cholesky=false, kwargs...)
    println("Solving decompositions")
    println("subset\n$subset\nend subset")
    query = "SELECT id, origin_id, origin_name, origin_scenario, clique_path, cliquetree_path, is_cholesky FROM decompositions"
    if !recompute
        query *= " WHERE solving_time IS NULL"
    end
    if !isnothing(subset)
        if !recompute
            query *= " AND id IN ($(join(subset, ',')))"
        else
            query *= " WHERE id IN ($(join(subset, ',')))"
        end
    end
    if cholesky
        if !recompute || !isnothing(subset)
            query *= " AND extension_alg = 'cholesky' AND preprocess_path='configs/preprocess_0.json'"
        else
            query *= " WHERE extension_alg = 'cholesky' AND preprocess_path='configs/preprocess_0.json'"
        end
    end
    results = DBInterface.execute(db, query) |> DataFrame
    # Retrieving mat and ctr path
    query = "SELECT id, mat_path, ctr_path FROM instances"
    matctr_paths = DBInterface.execute(db, query) |> DataFrame
    mat_paths = Dict(Pair.(matctr_paths[!, :id], matctr_paths[!, :mat_path]))
    ctr_paths = Dict(Pair.(matctr_paths[!, :id], matctr_paths[!, :ctr_path]))
    solve_decomposition_func!(row) = solve_decomposition_dfrow!(db, row[:id], row[:origin_id], row[:origin_name], row[:origin_scenario],
                                                                row[:clique_path], row[:cliquetree_path], row[:is_cholesky], mat_paths, ctr_paths)
    solve_decomposition_func!.(eachrow(results[!, [:id, :origin_id, :origin_name, :origin_scenario, :clique_path, :cliquetree_path, :is_cholesky]]))
end
