function save_features_instance!(db::SQLite.DB, name, scenario, source_type, source_path)
    println("Saving instance features: ($name, $scenario)")
    network = PowerFlowNetwork(source_path, source_type)
    merge_duplicate_branch!(network)
    features = get_features_instance(network)
    query = "UPDATE instances SET "
    for (feature_name, feature_value) in features
        if feature_value == Inf
            query *= "$feature_name = '+Infinity', "
        elseif feature_value == -Inf
            query *= "$feature_name = '-Infinity', "
        else
            query *= "$feature_name = $feature_value, "
        end
    end
    query = query[begin:end - 2]
    query *= " WHERE name = '$name' AND scenario = $scenario"
    execute_query(db, query)
end

function save_features_instance_dfrow!(db::SQLite.DB, row) 
    save_features_instance!(db, row[:name], row[:scenario], row[:source_type], row[:source_path])
end

function save_features_instances!(db::SQLite.DB; min_nv=typemin(Int), max_nv=typemax(Int), recompute=false, subset=nothing)
    query = "SELECT name, scenario, source_type, source_path FROM instances WHERE nbus >= $min_nv AND nbus <= $max_nv"
    if !recompute
        query *= " AND nb_edge IS NULL"
    end
    if !isnothing(subset)
        query *= " AND id IN ($(join(subset, ',')))"
    end
    results = DBInterface.execute(db, query) |> DataFrame
    println("Saving instance features config: min_nv=$min_nv, max_nv=$max_nv, recompute=$recompute")
    save_function!(row) = save_features_instance_dfrow!(db, row)
    save_function!.(eachrow(results[!, [:name, :scenario, :source_type, :source_path]]))
end
