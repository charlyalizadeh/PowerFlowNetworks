include("../../../src/PowerFlowNetworks.jl")
include("../general_settings.jl")
using .PowerFlowNetworks
using SQLite
using ArgParse


function parse_commandline()
    s = ArgParseSettings()
    import_general_settings!(s, ["db", "nbus_limit", "mpi", "toml_config"])
    @add_arg_table s begin
        "--extension_alg"
            help = "Algorithm used for the chordal extension."
            default = "cholesky"
        "--cliques_path"
            help = "Directory where to store the cliques."
            default = "data/cliques"
        "--cliquetrees_path"
            help = "Directory where to store the cliquetrees."
            default = "data/cliquetrees"
        "--graphs_path"
            help = "Where to store the graphs."
            default = "data/graphs_serialized/"
        "--preprocess_path"
            help = "JSON file containing the preprocess option."
            default = "configs/preprocess_default.json"
        "--kwargs_path"
            help = ".toml config files containing the configuration for the values for the `chordal_extension_kwargs` dictionary."
            arg_type = String
            default = "configs/chordal_extension.toml"
        "--kwargs_key"
            help = "Key corresponding to the section name in the .toml config files."
            arg_type = String
            default = "default"
    end
    return parse_args(s)
end

function main()
    args = parse_commandline()
    println(args)
    if args["toml_config"]
        args = overwrite_toml(args, args["toml_config_path"], args["toml_config_key"])
    end
    println(args)
    db = SQLite.DB(args["dbpath"])
    kwargs = strkey_to_symkey(args, ["extension_alg", "cliques_path", "cliquetrees_path", "graphs_path", "min_nv", "max_nv", "preprocess_path"])
    chordal_extension_kwargs = get_config_toml(args["kwargs_path"]; key_symbol=false)[args["kwargs_key"]]
    kwargs[:chordal_extension_kwargs] = chordal_extension_kwargs
    if args["mpi"]
        execute_process_mpi(db, "generate_decompositions", args["log_dir"]; kwargs...)
    else
        generate_decompositions!(db; kwargs...)
    end
end

main()
