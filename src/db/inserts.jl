function load_instance!(db::SQLite.DB,
                        name::AbstractString, scenario::Int,
                        source_path::AbstractString, source_type::AbstractString,
                        date::DateTime)
    query = """
    INSERT INTO instances(name, scenario, source_path, source_type, date) 
    VALUES('$name', $scenario, '$source_path', '$source_type', '$date')
    """
    DBInterface.execute(db, query)
end

function insert_decomposition!(db::SQLite.DB, uuid,
                               origin_name, origin_scenario, extension_alg,
                               preprocess_path, date,
                               clique_path, cliquetree_path; kwargs...)
    query = "INSERT INTO decompositions(uuid, origin_name, origin_scenario, extension_alg, preprocess_path, date, clique_path, cliquetree_path"
    features = [(k, v) for (k, v) in kwargs]
    for feature in features
        feature_name = feature[1]
        query *= ", $feature_name"
    end
    query *= ") VALUES('$uuid', '$origin_name', '$origin_scenario', '$extension_alg', '$preprocess_path', '$date', '$clique_path', '$cliquetree_path'"
    for feature in features
        feature_value = feature[2]
        query *= ", $feature_value"
    end
    query *= ")"
    DBInterface.execute(db, query)
end
