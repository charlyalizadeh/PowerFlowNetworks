function mpi_init()
    !MPI.Initialized() && MPI.Init()
    comm = MPI.COMM_WORLD
    rank = MPI.Comm_rank(comm)
    size = MPI.Comm_size(comm)
    return comm, rank, size
end

const process_functions = Dict(
    "save_basic_features_instances" => save_basic_features_instances!,
    "save_single_features_instances" => save_single_features_instances!,
    "save_features_instances" => save_features_instances!,
    "serialize_instances" => serialize_instances!,
    "generate_decompositions" => generate_decompositions!,
    "merge_decompositions" => merge_decompositions!,
    "combine_decompositions" => combine_decompositions!,
    "delete_duplicates" => delete_duplicates!,
    "export_matpowerm_instances" => export_matpowerm_instances!,
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
    "export_matpowerm_instances" => "instances",
    "solve_decompositions" => "decompositions",
    "load_matctr_instances" => "instances"
)

function execute_process_mpi(db::SQLite.DB, process_type, log_dir; kwargs...)
    comm, rank, size = mpi_init()
    nb_process = size - 1
    log_dir = joinpath(log_dir, process_type)
    !isdir(log_dir) && mkpath(log_dir)
    redirect_stdio(stdout=joinpath(log_dir, "$rank.txt"), stderr=joinpath(log_dir, "$rank.txt")) do
        println("Rank: $rank / $size")
        if rank == 0
            table = table_to_process[process_type]
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
            while !all(process_done)
                for i in 1:nb_process
                    has_recieved, status = MPI.Iprobe(i, 0, comm)
                    if has_recieved
                        query, status = MPI.recv(i, 0, comm)
                        query = String(query)
                        println("Recieved query: $query")
                        if query == "over"
                            println("Process $i over.")
                            process_done[i] = true
                        else
                            try
                                DBInterface.execute(db, query)
                            catch e
                                @warn query
                                rethrow()
                            end
                        end
                    end
                end
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
            process_functions[process_type](db; subset=indexes, kwargs...)
            println("Process done.")
            MPI.send(['o', 'v', 'e', 'r'], 0, 0, comm)
            println("Finalize.")
            MPI.Barrier(comm)
            MPI.Finalize()
        end
    end
end
