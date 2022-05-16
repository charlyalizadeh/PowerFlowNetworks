function _check_columns(db, table; min_nv=nothing, max_nv=nothing)
    println("Checking missing values of table $table")
    query = "SELECT * FROM $table"
    if !isnothing(min_nv) && !isnothing(max_nv)
         query *= " WHERE nb_vertex >= $min_nv AND nb_vertex <= $max_nv"
    end
    results = DBInterface.execute(db, query) |> DataFrame
    for col in names(results)
        values = results[!, col]
        nb_missing = sum(map(ismissing, values))
        nb_total = length(values)
        color = nb_missing == 0 ? Symbol("green") : nb_missing == nb_total ? Symbol("red") : Symbol("yellow")
        printstyled("$col: $nb_missing / $nb_total\n"; color=color)
    end
end

function _check_chordality(row)
    ismissing(row[:graph_path]) && return false
    g = load_graph(row[:graph_path])
    return ischordal(g)
end

function _check_connectivity(row)
    ismissing(row[:graph_path]) && return false
    g = load_graph(row[:graph_path])
    return is_connected(g)
end

function _check_self_loops(row)
    ismissing(row[:graph_path]) && return false
    g = load_graph(row[:graph_path])
    return !has_self_loops(g)
end

function _check_index_clique(row)
    if ismissing(row[:clique_path]) || ismissing(row[:cliquetree_path])
        return false
    end
    clique = read_clique(row[:clique_path])
    cliquetree = read_cliquetree(row[:cliquetree_path])
    for edge in cliquetree
        src = clique[edge[1]]
        dst = clique[edge[2]]
        if isempty(intersect(src, dst))
            return false
        end
    end
    return true
end

function _check_source_graph(db, row)
    if ismissing(row[:origin_name]) || ismissing(row[:origin_scenario])
        return false
    end
    results = DBInterface.execute(db, "SELECT graph_path FROM instances WHERE name = '$(row[:origin_name])' AND scenario = $(row[:origin_scenario])") |> DataFrame
    source_graph = load_graph(results[1, :graph_path])
    g = load_graph(row[:graph_path])
    source_edges = edges(source_graph)
    g_edges = edges(g)
    return !isequal(source_graph, g) && all(in(g_edges), source_edges) && vertices(g) == vertices(source_graph)
end

function _check_serialize_graph(row)
    ismissing(row[:graph_path]) && return false
    graph_path = row[:graph_path]
    return isfile(graph_path)
end

function _check_serialize_network(row)
    ismissing(row[:pfn_path]) && return false
    pfn_path = row[:pfn_path]
    return isfile(pfn_path)
end

function _check_basic_feature(row)
    return !ismissing(row[:nbus]) &&
           !ismissing(row[:nbranch]) &&
           !ismissing(row[:nbranch_unique]) &&
           !ismissing(row[:ngen])
end

const check_functions = Dict(
    "chordality" => _check_chordality,
    "connectivity" => _check_connectivity,
    "self_loops" => _check_self_loops,
    "index_clique" => _check_index_clique,
    "source_graph" => _check_source_graph,
    "serialize_graph" => _check_serialize_graph,
    "serialize_network" => _check_serialize_network,
    "basic_feature" => _check_basic_feature
)
const need_db = Dict(
    "chordality" => false,
    "connectivity" => false,
    "self_loops" => false,
    "index_clique" => false,
    "source_graph" => true,
    "serialize_graph" => false,
    "serialize_network" => false,
    "basic_feature" => false
)
const valid_check_instances = Dict(
    "chordality" => true,
    "connectivity" => true,
    "self_loops" => true,
    "index_clique" => false,
    "source_graph" => false,
    "serialize_graph" => true,
    "serialize_network" => true,
    "basic_feature" => true,
)
const valid_check_decompositions = Dict(
    "chordality" => true,
    "connectivity" => true,
    "self_loops" => true,
    "index_clique" => true,
    "source_graph" => true,
    "serialize_graph" => true,
    "serialize_network" => false,
    "basic_feature" => false
)
const valid_check = Dict(
    "instances" => valid_check_instances,
    "decompositions" => valid_check_decompositions
)

function _check_sanity(db::SQLite.DB, rows::DataFrame, check::String)
    if need_db[check]
        check_function(row) = check_functions[check](db, row)
        check_results = check_function.(eachrow(rows))
    else
        check_results = check_functions[check].(eachrow(rows))
    end
    return check_results
end

function _check_sanity(db::SQLite.DB, table::String, check::String; min_nv=nothing, max_nv=nothing, subset=nothing)
    if !(table in ["instances", "decompositions"])
        throw(DomainError("`table` must be either \"instances\" or \"decompositions\". Got $table"))
    end
    if !valid_check[table][check]
        error("$check is not a valid sanity check for table $table.")
    end
    query = "SELECT * FROM $table"
    if !isnothing(min_nv) && !isnothing(max_nv)
         query *= " WHERE nb_vertex >= $min_nv AND nb_vertex <= $max_nv"
    end
    if !isnothing(subset)
        if !isnothing(min_nv) && !isnothing(max_nv)
            query *= " AND id IN ($(join(subset, ',')))"
        else
            query *= " WHERE id IN ($(join(subset, ',')))"
        end
    end
    results = DBInterface.execute(db, query) |> DataFrame
    return _check_sanity(db, results, check)
end

function check_sanity(db::SQLite.DB; table, check, min_nv=nothing, max_nv=nothing, subset=nothing)
    check_results = _check_sanity(db, table, check; min_nv=min_nv, max_nv=max_nv, subset=subset)
    if !all(check_results)
        printstyled("The check \"$check\" on table \"$table\" failed.\n"; color=:red)
    else
        printstyled("The check \"$check\" on the table \"$table\" succeeded.\n"; color=:green)
    end
end

function check_sanity_mpi(db::SQLite.DB; table, check, log_dir, min_nv=nothing, max_nv=nothing, kwargs...)
    comm, rank, size = mpi_init()
    nb_process = size - 1
    log_dir = joinpath(log_dir, "check_sanity/$check")
    !isdir(log_dir) && mkpath(log_dir)
    redirect_stdio(stdout=joinpath(log_dir, "$rank.txt"), stderr=joinpath(log_dir, "$rank.txt")) do
        if rank == 0
            ids = get_table_ids(db, table)
            println("Number of ids: $(length(ids))")
            if isempty(ids)
                println("Nothing to process.")
                for i in 1:nb_process
                    println("Sending to $(i - 1): [-1]")
                    MPI.send([-1], i, 0, comm)
                end
            else
                nb_ids_per_chunk = Int(floor(length(ids) / nb_process))
                for i in 1:nb_process
                    start = (i - 1) * nb_ids_per_chunk + 1
                    stop = start + nb_ids_per_chunk
                    stop = stop > length(ids) ? length(ids) : stop
                    if i == nb_process && stop != length(ids)
                        stop = length(ids)
                    end
                    chunk = ids[start:stop]
                    println("Sending [$start -> $stop] to $(i):\n$chunk\n")
                    if isempty(chunk)
                        chunck = [-1]
                    end
                    MPI.send(chunk, i, 0, comm)
                end
            end
            process_done = zeros(Bool, nb_process)
            check_results = []
            while !all(process_done)
                for i in 1:nb_process
                    has_recieved, status = MPI.Iprobe(i, 0, comm)
                    if has_recieved
                        process_done[i] = true
                        current_check_results, status = MPI.recv(i, 0, comm)
                        check_results = vcat(check_results, current_check_results)
                    end
                end
            end
            if !all(check_results)
                printstyled("The check \"$check\" on table \"$table\" failed.\n"; color=:red)
            else
                printstyled("The check \"$check\" on the table \"$table\" succeeded.\n"; color=:green)
            end
            MPI.Barrier(comm)
            MPI.Finalize()
        else
            indexes, status = MPI.recv(0, 0, comm)
            if indexes == [-1]
                println("Nothing to process. Exiting.")
                MPI.Finalize()
                return
            end
            println("Recieved: $indexes")
            check_results = _check_sanity(db, table, check; min_nv=min_nv, max_nv=max_nv, subset=indexes)
            MPI.send(check_results, 0, 0, comm)
            println("Process done.")
            println("Finalize.")
            MPI.Barrier(comm)
            MPI.Finalize()
        end
    end
end
