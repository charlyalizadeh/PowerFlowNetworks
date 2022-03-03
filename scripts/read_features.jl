include("../src/PowerFlowNetworks.jl")
using .PowerFlowNetworks
using SQLite
using ArgParse


function parse_commandline()
    s = ArgParseSettings()
    @add_arg_table s begin
        "--dbpath", "-p"
            help = "Path of the sqlite database file."
            default = "data/PowerFlowNetworks.sqlite"
        "--serialize"
            help = "Wether to serialize or not."
            default = false
            action = :store_true
        "--serialize_path"
            help = "Where to store the serialize networks."
            default = "data/networks_serialize/"
        "--min_nv"
            help = "Minimum number of vertices a network had to have to be processed."
            arg_type = Int
            default = typemin(Int)
        "--max_nv"
            help = "Maximum number of vertices a network had to have to be processed."
            arg_type = Int
            default = typemax(Int)
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
    save_features_instances!(db;
                             serialize_network=parsed_args["serialize"], serialize_path=parsed_args["serialize_path"],
                             min_nv=parsed_args["min_nv"], max_nv=parsed_args["max_nv"],
                             recompute=parsed_args["recompute"])
end

main()
