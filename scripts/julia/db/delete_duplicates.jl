include("../../../src/PowerFlowNetworks.jl")
include("../general_settings.jl")
using .PowerFlowNetworks
using SQLite
using ArgParse


function parse_commandline()
    s = ArgParseSettings()
    import_general_settings!(s, ["db", "mpi"])
    return parse_args(s)
end

function main()
    args = parse_commandline()
    db = SQLite.DB(args["dbpath"])
    if args["mpi"]
        execute_process_mpi(db, "delete_duplicates", args["log_dir"])
    else
        delete_duplicates!(db)
    end
end

main()
