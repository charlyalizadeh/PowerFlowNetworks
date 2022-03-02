include("../src/PowerFlowNetworks.jl")
using .PowerFlowNetworks
using SQLite
using ArgParse


function parse_commandline()
    s = ArgParseSettings()
    @add_arg_table s begin
        "--dbpath", "-p"
            help = "Path of the sqlite database file."
            default = "data/PowerFlowNetwork.sqlite"
        "--recompute"
            help = "Wether to recompute the basic features if they're already not NULL in the database."
            default = false
            action = :store_true
    end
    return parse_args(s)
end

function main()
    parsed_args = parse_commandline()
    db = SQLite.DB(parsed_args["dbpath"])
    save_basic_features_instances!(db; recompute=parsed_args["recompute"])
end

main()
