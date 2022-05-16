include("../../../src/PowerFlowNetworks.jl")
include("../general_settings.jl")
using .PowerFlowNetworks
using SQLite
using ArgParse


function parse_commandline()
    s = ArgParseSettings()
    import_general_settings!(s, ["db", "nbus_limit", "recompute", "mpi"])
    return parse_args(s)
end

function main()
    args = parse_commandline()
    db = SQLite.DB(args["dbpath"])
    if args["mpi"]
        execute_process_mpi(db, "solve_decompositions", args["log_dir"])
    else
        solve_decompositions!(db)
    end
end

main()
