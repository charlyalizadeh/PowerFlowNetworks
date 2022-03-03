function save_features_instance!(db::SQLite.DB, name, scenario, source_type, source_path;
                                 serialize_network, serialize_path)
    println("Saving features: $name scenario $scenario")
    network = PowerFlowNetwork(source_path; format=source_type)
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

function save_basic_features_instance!(db::SQLite.DB, name, scenario, source_type, source_path)
    println("Saving features: $name scenario $scenario")
    _nbus = nbus(source_path; format=source_type)
    _nbranch_unique = nbranch(source_path; format=source_type, distinct_pair=true)
    _nbranch = nbranch(source_path; format=source_type)
    _ngen = ngen(source_path; format=source_type)
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
