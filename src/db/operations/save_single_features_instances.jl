function save_single_features_instance!(db::SQLite.DB, feature_names, use_network, name, scenario, source_type, source_path, pfn_path)
    println("Saving features $(feature_names): $name scenario $scenario")
    network = nothing
    if use_network
        network = ismissing(pfn_path) ? PowerFlowNetwork(source_path, source_type) : deserialize(pfn_path)
    end
    feature_values = Dict()
    query = "UPDATE instances SET "
    for feature_name in feature_names
        feature_info = _feature_info_dict[feature_name]
        if feature_info[1] == :graph
            g = SimpleGraph(network)
            feature_value = get_single_feature_graph(feature_name, g)
        elseif feature_info[1] == :network
            feature_value = get_single_feature_network(feature_name, network)
        elseif feature_info[1] == :source_path
            feature_value = get_single_feature_source_path(feature_name, source_path)
        end
        if feature_info[2]
            query *= """
            $(feature_name)_max = $(feature_value[1]),
            $(feature_name)_min = $(feature_value[2]),
            $(feature_name)_mean = $(feature_value[3]),
            """
        else
            query *= "$(feature_name) = $(feature_value),"
        end
    end
    query = query[begin:end - 1] * " WHERE name = '$name' AND scenario = $scenario"
    DBInterface.execute(db, query)
end

function save_single_features_instance_dfrow!(db::SQLite.DB, feature_names, use_network, row)
    save_single_features_instance!(db, feature_names, use_network, row[:name], row[:scenario], row[:source_type], row[:source_path], row[:pfn_path])
end

function save_single_features_instances!(db::SQLite.DB, feature_names;
                                         min_nv=typemin(Int), max_nv=typemax(Int), recompute=false, subset=nothing)
    query = "SELECT name, scenario, source_type, source_path, pfn_path FROM instances WHERE nbus >= $min_nv AND nbus <= $max_nv"
    if !recompute
        for feature_name in feature_names
            query *= " AND $feature_name IS NULL"
        end
    end
    if !isnothing(subset)
        subset = ["('$(s[1])', $(s[2]))" for s in subset]
        query *= " AND (name, scenario) IN ($(join(subset, ',')))"
    end
    use_network = any([_feature_info_dict[f][1] in (:graph, :network) for f in feature_names])
    results = DBInterface.execute(db, query) |> DataFrame
    save_func!(row) = save_single_features_instance_dfrow!(db, feature_names, use_network, row)
    save_func!.(eachrow(results[!, [:name, :scenario, :source_type, :source_path, :pfn_path]]))
end
