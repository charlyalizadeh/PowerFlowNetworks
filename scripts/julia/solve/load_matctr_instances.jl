include("../../../src/PowerFlowNetworks.jl")
include("../general_settings.jl")
using .PowerFlowNetworks
using SQLite
using ArgParse


function parse_commandline()
    s = ArgParseSettings()
    import_general_settings!(s, ["db", "nbus_limit", "recompute", "mpi", "toml_config"])
    @add_arg_table s begin
        "--out"
            help = "Directory where the mat and ctr files are"
            default = "data/matctr"
    end
    return parse_args(s)
end

function main()
    args = parse_commandline()
    if args["toml_config"]
        overwrite_args!(args, args["toml_config_path"], args["toml_config_key"])
    end
    db = SQLite.DB(args["dbpath"])
    kwargs = strkey_to_symkey(args, ["out"])
    if args["mpi"]
        execute_process_mpi(db, "load_matctr_instances", args["log_dir"]; kwargs...)
    else
        load_matctr_instances!(db; kwargs...)
    end
end

main()
