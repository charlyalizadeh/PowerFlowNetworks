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
    "combine_decompositions" => combine_decompositions!
)
const table_to_process = Dict(
    "save_basic_features_instances" => "instances",
    "save_single_features_instances" => "instances",
    "save_features_instances" => "instances",
    "serialize_instances" => "instances",
    "generate_decompositions" => "instances",
    "merge_decompositions" => "decompositions",
    "combine_decompositions" => "instances"
)

function execute_process_mpi(db::SQLite.DB, process_type, log_dir; kwargs...)
    comm, rank, size = mpi_init()
    log_dir = joinpath(log_dir, process_type)
    !isdir(log_dir) && mkpath(log_dir)
    io = open(joinpath(log_dir, "$rank.txt"), "w+")
    logger = ConsoleLogger(io, meta_formatter=(args...) -> (:white, "", ""))
    with_logger(logger) do
        @info "Rank: $rank / $size"
        if rank == 0
            table = table_to_process[process_type]
            ids = get_table_ids(db, table)
            if isempty(ids)
                @info "Nothing to process."
                for i in 1:size
                    @info "Sending to $(i - 1): []"
                    MPI.Isend(Vector{Int}(), i - 1, 0, comm)
                end
            else
                nb_ids_per_chunk = Int(floor(length(ids) / size))
                for i in 1:size
                    start = (i - 1) * nb_ids_per_chunk + 1
                    stop = start + nb_ids_per_chunk
                    stop = stop > length(ids) ? length(ids) : stop
                    chunk = ids[start:stop]
                    @info "Sending to $(i - 1):\n$chunk"
                    MPI.Isend(chunk, i - 1, 0, comm)
                end
            end
        end
        MPI.Barrier(comm)
        status = MPI.Probe(0, 0, comm)
        count = MPI.Get_count(status, Int)
        if count == 0
            @info "Nothing to process. Exciting."
            return
        end
        indexes = Array{Int}(undef, count)
        MPI.Irecv!(indexes, 0, 0, comm)
        @info "Recieved: $indexes"
        process_functions[process_type](db; subset=indexes, kwargs...)
        @info "Process done."
    end
end
