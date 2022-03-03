# Save features
function save_features_instance!(db::SQLite.DB, name, scenario, source_type, source_path;
                                 serialize_network, serialize_path)
    println("Saving features: $name scenario $scenario")
    network = PowerFlowNetwork(source_path, source_type)
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

    # Serialize the `PowerFlowNetwork` object
    if serialize_network
        serialize_path = joinpath(serialize_path, "$(name)_$(scenario)")
        serialize(serialize_path, network)
        query *= "source_pfn = '$serialize_path', "
    end

    query = query[begin:end - 2]
    query *= " WHERE name = '$name' AND scenario = $scenario"
    DBInterface.execute(db, query)
end
function save_features_instance_dfrow!(db::SQLite.DB, row; serialize_network, serialize_path) 
    save_features_instance!(db, row[:name], row[:scenario], row[:source_type], row[:source_path];
                            serialize_network=serialize_network, serialize_path=serialize_path)
end
function save_features_instances!(db::SQLite.DB; serialize_network, serialize_path,
                                  min_nv=typemin(Int), max_nv=typemax(Int), recompute=false)
    serialize_network && mkpath(serialize_path)
    query = "SELECT name, scenario, source_type, source_path FROM instances WHERE nbus >= $min_nv AND nbus <= $max_nv"
    if !recompute
        query *= " AND nb_edge IS NULL"
    end
    results = DBInterface.execute(db, query) |> DataFrame
    save_func!(row) = save_features_instance_dfrow!(db, row;
                                                    serialize_network=serialize_network, serialize_path=serialize_path)
    save_func!.(eachrow(results[!, [:name, :scenario, :source_type, :source_path]]))
end

# Save basic features
function save_basic_features_instance!(db::SQLite.DB, name, scenario, source_type, source_path)
    println("Saving features: $name scenario $scenario")
    _nbus = nbus(source_path, source_type)
    _nbranch_unique = nbranch(source_path, source_type; distinct_pair=true)
    _nbranch = nbranch(source_path, source_type)
    _ngen = ngen(source_path, source_type)
    query = """
    UPDATE instances
    SET nbus = $_nbus, nbranch_unique = $_nbranch_unique, nbranch = $_nbranch, ngen = $_ngen
    WHERE name = '$name' AND scenario = $scenario;
    """
    DBInterface.execute(db, query)
end
function save_basic_features_instance_dfrow!(db::SQLite.DB, row)
    save_basic_features_instance!(db, row[:name], row[:scenario], row[:source_type], row[:source_path])
end
function save_basic_features_instances!(db::SQLite.DB; recompute=false)
    query = "SELECT name, scenario, source_type, source_path FROM instances"
    if !recompute
        query *= " WHERE nbus IS NULL OR nbranch_unique IS NULL OR nbranch IS NULL OR ngen IS NULL"
    end
    results = DBInterface.execute(db, query) |> DataFrame
    save_func!(row) = save_basic_features_instance_dfrow!(db, row)
    save_func!.(eachrow(results[!, [:name, :scenario, :source_type, :source_path]]))
end

# Save single features
function save_single_features_instance!(db::SQLite.DB, feature_names, use_network, name, scenario, source_type, source_path, source_pfn)
    println("Saving features $(feature_names): $name scenario $scenario")
    network = nothing
    if use_network
        network = ismissing(source_pfn) ? PowerFlowNetwork(source_path, source_type) : deserialize(source_pfn)
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
    save_single_features_instance!(db, feature_names, use_network, row[:name], row[:scenario], row[:source_type], row[:source_path], row[:source_pfn])
end
function save_single_features_instances!(db::SQLite.DB, feature_names;
                                         min_nv=typemin(Int), max_nv=typemax(Int), recompute=false)
    query = "SELECT name, scenario, source_type, source_path, source_pfn FROM instances WHERE nbus >= $min_nv AND nbus <= $max_nv"
    if !recompute
        for feature_name in feature_names
            query *= " AND $feature_name IS NULL"
        end
    end
    use_network = any([_feature_info_dict[f][1] in (:graph, :network) for f in feature_names])
    results = DBInterface.execute(db, query) |> DataFrame
    save_func!(row) = save_single_features_instance_dfrow!(db, feature_names, use_network, row)
    save_func!.(eachrow(results[!, [:name, :scenario, :source_type, :source_path, :source_pfn]]))
end

# Serialize
function serialize_instance!(db::SQLite.DB, serialize_path, name, scenario, source_type, source_path)
    println("Serializing: $name scenario $scenario")
    serialize_path = abspath(joinpath(serialize_path, "$(name)_$(scenario)"))
    serialize(serialize_path, network)
    query = "UPDATE instances SET source_pfn = '$serialize_path' WHERE name = '$name' AND scenario = $scenario"
    DBInterface.execute(db, query)
end
function serialize_instance_dfrow!(db::SQLite.DB, serialize_path, row)
    save_single_features_instance!(db, serialize_path, row[:name], row[:scenario], row[:source_type], row[:source_path])
end
function serialize_instance_instances!(db::SQLite.DB, serialize_path;
                                       min_nv=typemin(Int), max_nv=typemax(Int), recompute=false)
    query = "SELECT name, scenario, source_type, source_path FROM instances WHERE nbus >= $min_nv AND nbus <= $max_nv"
    if !recompute
        query *= " AND $source_pfn IS NULL"
    end
    results = DBInterface.execute(db, query) |> DataFrame
    save_func!(row) = save_single_features_instance_dfrow!(db, serialize_path, row)
    save_func!.(eachrow(results[!, [:name, :scenario, :source_type, :source_path]]))
end
