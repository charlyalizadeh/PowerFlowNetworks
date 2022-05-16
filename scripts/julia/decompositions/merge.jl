include("../../../src/PowerFlowNetworks.jl")
include("../general_settings.jl")
using .PowerFlowNetworks
using SQLite
using ArgParse


function parse_commandline()
    s = ArgParseSettings()
    import_general_settings!(s, ["db", "nbus_limit", "recompute", "mpi", "toml_config"])
    @add_arg_table s begin
        "--heuristic"
            help = "Algorithm(s) used for the chordal extension."
            arg_type = Vector{String}
            default = ["molzahn"]
        "--heuristic_switch"
            help = "Iteration(s) when to switch the heuristic."
            arg_type = Vector{Int}
            default = [0]
        "--treshold_name"
            help = "Name of the treshold used to stop the merge."
            arg_type = String
            default = "clique_nv_up"
        "--kwargs_path"
            help = ".toml config files containing the configuration for the values for the `merge_kwargs` dictionary."
            arg_type = String
            default = "configs/merge.toml"
        "--kwargs_key"
            help = "Key corresponding to the section name in the .toml merge config files."
            arg_type = String
            default = "default"
    end
    return parse_args(s)
end

function main()
    args = parse_commandline()
    if args["toml_config"]
        overwrite_toml!(args, args["toml_config_path"], args["toml_config_key"])
    end
    db = SQLite.DB(args["dbpath"])
    if "sliwak" in args["heuristic"]
        error("Sliwak merge not implemented yet.")
    end
    merge_kwargs = get_config_toml(args["kwargs_path"]; key_symbol=false)[args["kwargs_key"]]
    kwargs = strkey_to_symkey(args, ["heuristic", "heuristic_switch", "treshold_name", "min_nv", "max_nv", "subset"])
    kwargs[:merge_kwargs] = merge_kwargs
    if args["mpi"]
        execute_process_mpi(db, "merge_decompositions", args["log_dir"]; kwargs...)
    else
        merge_decompositions!(db; kwargs...)
    end
end

main()
