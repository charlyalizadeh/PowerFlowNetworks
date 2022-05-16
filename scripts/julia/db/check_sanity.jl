include("../../../src/PowerFlowNetworks.jl")
include("../general_settings.jl")
using .PowerFlowNetworks
using SQLite
using ArgParse


function parse_commandline()
    s = ArgParseSettings()
    import_general_settings!(s, ["db", "nbus_limit", "mpi", "toml_config"])
    @add_arg_table s begin
        "--check"
            help = "Name of the check to apply on the database."
            arg_type = String
        "--table"
            help = "Table on which to apply the sanity check."
            arg_type = String
    end
    return parse_args(s)
end

function main()
    args = parse_commandline()
    if args["toml_config"]
        overwrite_toml!(args, args["toml_config_path"], args["toml_config_key"])
    end
    db = SQLite.DB(args["dbpath"])
    kwargs = strkey_to_symkey(args, ["table", "check", "log_dir", "min_nv", "max_nv"])
    if args["mpi"]
        check_sanity_mpi(db; kwargs...)
    else
        check_sanity(db; kwargs...)
    end
end

main()
