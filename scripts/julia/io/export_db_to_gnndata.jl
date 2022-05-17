include("../../../src/PowerFlowNetworks.jl")
include("../general_settings.jl")
using .PowerFlowNetworks
using SQLite
using ArgParse


function parse_commandline()
    s = ArgParseSettings()
    import_general_settings!(s, ["db"])
    @add_arg_table s begin
        "--out"
            help = "Directory where to the gnndata."
            default = "data/gnndata"
    end
    return parse_args(s)
end

function main()
    args = parse_commandline()
    db = SQLite.DB(args["dbpath"])
    out = args["out"]
    export_db_to_gnndata(db, out)
end

main()
