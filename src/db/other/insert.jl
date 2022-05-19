function execute_query(db, query; wait_until_executed=false, time_to_sleep=0, return_results=false)
    if !MPI.Initialized()
        DBInterface.execute(db, query)
    elseif return_results
        query = "[RETURN]" * query
        query = [c for c in query]
        MPI.send(query, 0, 0, MPI.COMM_WORLD)
        while true
            has_recieved, status = MPI.Iprobe(0, 0, MPI.COMM_WORLD)
            if has_recieved
                query, status = MPI.recv(0, 0, MPI.COMM_WORLD)
                query = String(query)
                return DataFame(CSV.File(IOBuffer(query)))
            end
        end
    elseif wait_until_executed
        query = "[WAIT]" * query
        query = [c for c in query]
        MPI.send(query, 0, 0, MPI.COMM_WORLD)
        while true
            has_recieved, status = MPI.Iprobe(0, 0, MPI.COMM_WORLD)
            if has_recieved
                query, status = MPI.recv(0, 0, MPI.COMM_WORLD)
                query = String(query)
                if query == "executed"
                    return
                end
            end
        end
    elseif time_to_sleep > 0
        query = "[SLEEP][$time_to_sleep]" * query
        query = [c for c in query]
        MPI.send(query, 0, 0, MPI.COMM_WORLD)
    else
        query = [c for c in query]
        MPI.send(query, 0, 0, MPI.COMM_WORLD)
    end
end

function execute_query_once(db, query)
    if !MPI.Initialized()
        DBInterface.execute(db, query)
    else
        comm = MPI.COMM_WORLD
        rank = MPI.Comm_rank(comm)
        size = MPI.Comm_size(comm)
        if rank == 1
            DBInterface.execute(db, query)
            MPI.send(['B', 'a', 'r', 'r', 'i', 'e', 'r'], 0, 0, comm)
        end
        MPI.Barrier(comm)
    end
end

function load_in_db_instance!(db::SQLite.DB,
                              name::AbstractString, scenario::Int,
                              source_path::AbstractString, source_type::AbstractString,
                              date::DateTime)
    query = """
    INSERT INTO instances(name, scenario, source_path, source_type, date) 
    VALUES('$name', $scenario, '$source_path', '$source_type', '$date');
    """
    execute_query(db, query)
end

function insert_decomposition!(db::SQLite.DB, origin_id, uuid,
                               origin_name, origin_scenario, extension_alg,
                               preprocess_path, date,
                               clique_path, cliquetree_path, graph_path; wait_until_executed=false, kwargs...)
    query = "INSERT INTO decompositions(uuid, origin_id, origin_name, origin_scenario, extension_alg, preprocess_path, date, clique_path, cliquetree_path, graph_path"
    features = [(k, v) for (k, v) in kwargs]
    for feature in features
        feature_name = feature[1]
        query *= ", $feature_name"
    end
    query *= ") VALUES('$uuid', $origin_id, '$origin_name', '$origin_scenario', '$extension_alg', '$preprocess_path', '$date', '$clique_path', '$cliquetree_path', '$graph_path'"
    for feature in features
        feature_value = feature[2]
        query *= ", $feature_value"
    end
    query *= ");"
    execute_query(db, query; wait_until_executed=wait_until_executed)
end

function insert_merge!(db::SQLite.DB, in_id::Int, out_id::Int,
                       heuristics::AbstractString, treshold_name::AbstractString,
                       treshold_percent::Float64, nb_added_edge::Int)
    query = """
    INSERT INTO merges(in_id, out_id, heuristics, treshold_name, treshold_percent, nb_added_edge)
    VALUES ($in_id, $out_id, '$heuristics', '$treshold_name', $treshold_percent, $nb_added_edge);
    """
    execute_query(db, query)
end

function insert_combination!(db::SQLite.DB, in_id1::Int, in_id2::Int, out_id::Int,
                             how::AbstractString, extension_alg::AbstractString)
    query = """
    INSERT INTO combinations(in_id1, in_id2, out_id, how, extension_alg)
    VALUES ($in_id1, $in_id2, $out_id, '$how', '$extension_alg');
    """
    execute_query(db, query)
end
