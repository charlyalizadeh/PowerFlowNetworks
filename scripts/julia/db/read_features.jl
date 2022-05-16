include("../../../src/PowerFlowNetworks.jl")
include("../general_settings.jl")
using .PowerFlowNetworks
using SQLite
using ArgParse


function parse_commandline()
    s = ArgParseSettings()
    import_general_settings!(s, ["db", "nbus_limit", "recompute", "mpi", "toml_config"])
    return parse_args(s)
end

function main()
    args = parse_commandline()
    if args["toml_config"]
        overwrite_toml!(args, args["toml_config_path"], args["toml_config_key"])
    end
    db = SQLite.DB(args["dbpath"])
    kwargs = strkey_to_symkey(args, ["min_nv", "max_nv", "recompute"])
    if args["mpi"]
        execute_process_mpi(db, "save_features_instances", args["log_dir"]; kwargs...)
    else
        save_features_instances!(db; min_nv=args["min_nv"], max_nv=args["max_nv"], recompute=args["recompute"])
    end
end


main()
