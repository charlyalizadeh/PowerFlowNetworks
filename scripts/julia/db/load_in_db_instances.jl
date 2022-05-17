include("../../../src/PowerFlowNetworks.jl")
include("../general_settings.jl")
using .PowerFlowNetworks
using SQLite
using ArgParse


function parse_commandline()
    s = ArgParseSettings()
    import_general_settings!(s, ["db", "toml_config"])
    @add_arg_table s begin
        "--indirs_rawgo"
            help = "Directory/ies containing the RAWGO networks."
            arg_type = Vector{String}
            default = readdir("data/RAWGO"; join=true)
        "--indirs_matpowerm"
            help = "Directory/ies containing the MATPOWERM networks."
            arg_type = Vector{String}
            default = ["data/MATPOWERM"]
    end
    return parse_args(s)
end

function main()
    args = parse_commandline()
    if args["toml_config"]
        args = overwrite_toml(args, args["toml_config_path"], args["toml_config_key"])
    end
    db = SQLite.DB(args["dbpath"])
    load_in_db_instances!(db, args["indirs_rawgo"], args["indirs_matpowerm"])
end

main()
