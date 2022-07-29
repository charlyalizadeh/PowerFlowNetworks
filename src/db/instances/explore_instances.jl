function save_features_instance(db::SQLite.DB, path, id, name, scenario)
    println("Exploring instance: ($name, $scenario)")
    query = "SELECT * FROM decompositions WHERE origin_id = $id AND solving_time IS NOT NULL AND solving_time != 'NaN'"
    results = execute_query(db, query, return_results=true)
    @df results boxplot(:degree_min)
    @df results boxplot!(:degree_max)
    @df results boxplot!(:degree_mean)
    Plots.savefig(joinpath(path, "degree_$(id).png"))
end

function explore_instances(db::SQLite.DB; path, min_nv=typemin(Int), max_nv=typemax(Int), subset=nothing, kwargs...)
    query = "SELECT * FROM instances WHERE nbus >= $min_nv AND nbus <= $max_nv "
    if !isnothing(subset)
        query *= " WHERE id IN ($(join(subset, ',')))"
    end
    results = DBInterface.execute(db, query) |> DataFrame
    println("Exploring instances config: min_nv=$min_nv, max_nv=$max_nv")
    save_function!(row) = save_features_instance!(db, row[:name], row[:scenario], row[:network_path], row[:source_type], row[:source_path])
    save_function!.(eachrow(results))
end
