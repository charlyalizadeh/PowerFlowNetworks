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
                               clique_path, cliquetree_path, graph_path; kwargs...)
    query = "INSERT INTO decompositions(uuid, origin_name, origin_scenario, extension_alg, preprocess_path, date, clique_path, cliquetree_path, graph_path"
    features = [(k, v) for (k, v) in kwargs]
    for feature in features
        feature_name = feature[1]
        query *= ", $feature_name"
    end
    query *= ") VALUES('$uuid', '$origin_name', '$origin_scenario', '$extension_alg', '$preprocess_path', '$date', '$clique_path', '$cliquetree_path', '$graph_path'"
    for feature in features
        feature_value = feature[2]
        query *= ", $feature_value"
    end
    query *= ")"
    DBInterface.execute(db, query)
end

function insert_merge!(db::SQLite.DB, in_id::Int, out_id::Int,
                       heuristics::AbstractString, treshold_name::AbstractString,
                       treshold_percent::Float64, nb_edge_added::Int)
    query = """
    INSERT INTO merges(in_id, out_id, heuristics, treshold_name, treshold_percent, nb_edge_added)
    VALUES ($in_id, $out_id, '$heuristics', '$treshold_name', $treshold_percent, $nb_edge_added)
    """
    DBInterface.execute(db, query)
end

function insert_combination!(db::SQLite.DB, in_id1::Int, in_id2::Int, out_id::Int,
                             how::AbstractString, extension_alg::AbstractString)

    query = """
    INSERT INTO combinations(in_id1, in_id2, out_id, how, extension_alg)
    VALUES ($in_id1, $in_id2, $out_id, '$how', '$extension_alg')
    """
    DBInterface.execute(db, query)
end
