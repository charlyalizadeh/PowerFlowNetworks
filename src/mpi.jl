const process_functions = Dict(
    "save_basic_features_instances" => save_basic_features_instances!,
    "save_single_features_instances" => save_single_features_instances!,
    "save_features_instances" => save_features_instances!,
    "serialize_instances" => serialize_instances!,
    "generate_decompositions" => generate_decompositions!,
    "merge_decompositions" => merge_decompositions!,
    "combine_decompositions" => combine_decompositions!,
    "delete_duplicates" => delete_duplicates!,
    "export_instances" => export_instances!,
    "solve_decompositions" => solve_decompositions!,
    "load_matctr_instances" => load_matctr_instances!
)
const table_to_process = Dict(
    "save_basic_features_instances" => "instances",
    "save_single_features_instances" => "instances",
    "save_features_instances" => "instances",
    "serialize_instances" => "instances",
    "generate_decompositions" => "instances",
    "merge_decompositions" => "decompositions",
    "combine_decompositions" => "instances",
    "delete_duplicates" => "instances",
    "export_instances" => "instances",
    "solve_decompositions" => "decompositions",
    "load_matctr_instances" => "instances"
)

function mpi_init()
    !MPI.Initialized() && MPI.Init()
    rank = MPI.Comm_rank(MPI.COMM_WORLD)
    size = MPI.Comm_size(MPI.COMM_WORLD)
    return MPI.COMM_WORLD, rank, size
end

function assign_indexes(db::SQLite.DB, table::String)
    size = MPI.Comm_size(MPI.COMM_WORLD)
    nb_process = size - 1
    ids = get_table_ids(db, table)
    println("Number of ids: $(length(ids))")
    if isempty(ids)
        println("Nothing to process.")
        for i in 1:nb_process
            println("Sending to $(i - 1): [-1]")
            MPI.send([-1], i, 0, MPI.COMM_WORLD)
        end
    elseif length(ids) <= nb_process
        for i in 1:length(ids)
            println("Sending to $(i - 1): [$(ids[i])]")
            MPI.send([ids[i]], i, 0, MPI.COMM_WORLD)
        end
        for i in length(ids):nb_process
            println("Sending to $(i - 1): [-1]")
            MPI.send([-1], i, 0, MPI.COMM_WORLD)
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
            MPI.send(chunk, i, 0, MPI.COMM_WORLD)
        end
    end
end

function get_query_part(query)
    query = replace(query, "[" => "")
    return split(query, "]")
end

function df_to_str(df)
    io = IOBuffer()
    CSV.write(io, df)
    return String(take!(io))
end

function process_query(db::SQLite.DB, query)
    query = String(query)
    println("[$i] Recieved query: $query")
    if query == "over"
        println("Process $i over.")
        process_done[i] = true
    elseif query == "Barrier"
        MPI.Barrier(MPI.COMM_WORLD)
    else
        query_parts = get_query_part(query)
        if query_parts[1] == "WAIT"
            DBInterface.execute(db, query_parts[2])
            MPI.send(['e', 'x', 'e', 'c', 'u', 't', 'e', 'd'], i, 0, MPI.COMM_WORLD)
        elseif query_parts[1] == "SLEEP"
            time_to_sleep = parse(Float64, query_parts[2])
            DBInterface.execute(db, query_parts[3])
        elseif query_parts[1] == "RETURN"
            results = DBInterface.execute(db, query_parts[2]) |> DataFrame
            results_str = df_to_str(results)
            MPI.send([c for c in results_str], i, 0, MPI.COMM_WORLD)
        else
            DBInterface.execute(db, query_parts[1])
        end
        try
            DBInterface.execute(db, query)
        catch e
            @warn query
            rethrow()
        end
    end
end

function listen_queries(db::SQLite.DB)
    size = MPI.Comm_size(MPI.COMM_WORLD)
    nb_process = size - 1
    process_done = zeros(Bool, nb_process)
    while !all(process_done)
        for i in 1:nb_process
            has_recieved, status = MPI.Iprobe(i, 0, MPI.COMM_WORLD)
            if has_recieved
                query, status = MPI.recv(i, 0, MPI.COMM_WORLD)
                end
            end
        end
    end
end

function execute_process_main(db::SQLite.DB, process_type::String; kwargs...)
    table = table_to_process[process_type]
    assign_indexes(db, table)
    listen_queries(db)
    MPI.Barrier(MPI.COMM_WORLD)
    MPI.Finalize()
end

function execute_process_secondary(db::SQLite.DB, process_type::String; kwargs...)
    indexes, status = MPI.recv(0, 0, MPI.COMM_WORLD)
    if indexes == [-1]
        println("Nothing to process. Exiting.")
        MPI.Finalize()
        return
    end
    println("Recieved: $indexes")
    process_functions[process_type](db; subset=indexes, kwargs...)
    println("Process done.")
    MPI.send(['o', 'v', 'e', 'r'], 0, 0, MPI.COMM_WORLD)
    println("Finalize.")
    MPI.Barrier(MPI.COMM_WORLD)
    MPI.Finalize()
end

function execute_process_mpi(db::SQLite.DB, process_type, log_dir; kwargs...)
    comm, rank, size = mpi_init()
    log_dir = joinpath(log_dir, process_type)
    !isdir(log_dir) && mkpath(log_dir)
    redirect_stdio(stdout=joinpath(log_dir, "$rank.txt"), stderr=joinpath(log_dir, "$rank.txt")) do
        println("Rank: $rank / $size")
        if rank == 0
            execute_process_main(db, process_type; kwargs...)
        else
            execute_process_secondary(db, process_type; kwargs...)
        end
    end
end
