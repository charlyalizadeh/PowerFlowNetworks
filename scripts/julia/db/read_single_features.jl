include("../../../src/PowerFlowNetworks.jl")
include("../general_settings.jl")
using .PowerFlowNetworks
using SQLite
using ArgParse


function parse_commandline()
    s = ArgParseSettings()
    import_general_settings(s, ["db", "nbus_limit", "recompute", "mpi", "toml_config"])
    @add_arg_table s begin
        "--feature_names"
            help = "Feature(s) name(s) to compute"
            required = true
            arg_type = Vector{String}
    end
    return parse_args(s)
end

function main()
    args = parse_commandline()
    if args["toml_config"]
        overwrite_args!(args, args["toml_config_path"], args["toml_config_key"])
    end
    db = SQLite.DB(args["dbpath"])
    kwargs = strkey_to_symkey(args, ["feature_names", "min_nv", "max_nv", "recompute"])
    if args["mpi"]
        execute_process_mpi(db, "save_single_features_instances", args["log_dir"]; kwargs...)
    else
        save_single_features_instances!(db; kwargs...)
    end
end

main()
