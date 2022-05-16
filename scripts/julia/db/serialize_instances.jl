include("../../../src/PowerFlowNetworks.jl")
include("../general_settings.jl")
using .PowerFlowNetworks
using SQLite
using ArgParse


function parse_commandline()
    s = ArgParseSettings()
    import_general_settings!(s, ["db", "nbus_limit", "recompute", "mpi", "toml_config"])
    @add_arg_table s begin
        "--serialize_path"
            help = "Where to store the serialize networks."
            default = "data/networks_serialized/"
        "--graphs_path"
            help = "Where to store the graphs."
            default = "data/graphs_serialized/"
    end
    return parse_args(s)
end

function main()
    args = parse_commandline()
    if args["toml_config"]
        overwrite_toml!(args, args["toml_config_path"], args["toml_config_key"])
    end
    db = SQLite.DB(args["dbpath"])
    kwargs = strkey_to_symkey(args, ["serialize_path", "graphs_path", "min_nv", "max_nv", "subset", "recompute"])
    if args["mpi"]
        execute_process_mpi(db, "serialize_instances", args["log_dir"]; kwargs...)
    else
        serialize_instances!(db; kwargs...)
    end
end

main()
