function save_single_features_instance!(db::SQLite.DB, feature_names, use_network, name, scenario, source_type, source_path, network_path)
    println("Saving instance features: ($name, $scenario)")
    network = nothing
    if use_network
        network = ismissing(network_path) ? PowerFlowNetwork(source_path, source_type) : load_network(network_path)
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
    execute_query(db, query)
end

function save_single_features_instances!(db::SQLite.DB;
                                         feature_names, min_nv=typemin(Int), max_nv=typemax(Int),
                                         recompute=false, subset=nothing, kwargs...)
    query = "SELECT name, scenario, source_type, source_path, network_path FROM instances WHERE nbus >= $min_nv AND nbus <= $max_nv"
    if !recompute
        for feature_name in feature_names
            query *= " AND $feature_name IS NULL"
        end
    end
    if !isnothing(subset)
        query *= " AND id IN ($(join(subset, ',')))"
    end
    use_network = any([_feature_info_dict[f][1] in (:graph, :network) for f in feature_names])
    results = DBInterface.execute(db, query) |> DataFrame
    println("Saving instance features: feature_names=$(feature_names), min_nv=$min_nv, max_nv=$max_nv, recompute=$recompute")
    println("subset\n$subset\nend subset")
    save_function!(row) = save_single_features_instance!(db, feature_names, use_network, row[:name], row[:scenario], row[:source_type], row[:source_path], row[:network_path])
    save_function!.(eachrow(results))
end
