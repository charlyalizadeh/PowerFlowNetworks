include("../../../src/PowerFlowNetworks.jl")
include("../general_settings.jl")
using .PowerFlowNetworks
using SQLite
using ArgParse


function parse_commandline()
    s = ArgParseSettings()
    import_general_settings!(s, ["db", "nbus_limit", "recompute", "mpi"])
    @add_arg_table s begin
        "--cholesky"
            help = "Wether to solve only default Cholesky decomposition."
            default = false
            action = :store_true
    end
    return parse_args(s)
end

function main()
    args = parse_commandline()
    db = SQLite.DB(args["dbpath"])
    kwargs = strkey_to_symkey(args, ["recompute", "cholesky"])
    if args["mpi"]
        execute_process_mpi(db, "solve_decompositions", args["log_dir"]; kwargs...)
    else
        solve_decompositions!(db; kwargs...)
    end
end

main()
