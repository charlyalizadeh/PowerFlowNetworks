include("../src/PowerFlowNetworks.jl")
using .PowerFlowNetworks
using SQLite
using ArgParse


ArgParse.parse_item(::Type{Vector{String}}, x::AbstractString) = split(x, ",")

function parse_commandline()
    s = ArgParseSettings()
    @add_arg_table s begin
        "--dbpath", "-p"
            help = "Path of the sqlite database file."
            default = "data/PowerFlowNetworks.sqlite"
        "--min_nv"
            help = "Minimum number of vertices a network had to have to be processed."
            arg_type = Int
            default = typemin(Int)
        "--max_nv"
            help = "Maximum number of vertices a network had to have to be processed."
            arg_type = Int
            default = typemax(Int)
        "--serialize_path"
            help = "Where to store the serialize networks."
            default = "data/networks_serialize/"
        "--recompute"
            help = "Wether to restore the serialize `PowerFlowNetwork` object if the path already exists in the database."
            default = false
            action = :store_true
    end
    return parse_args(s)
end

function main()
    parsed_args = parse_commandline()
    db = SQLite.DB(parsed_args["dbpath"])
    serialize_instances!(db, parsed_args["serialize_path"];
                         min_nv=parsed_args["min_nv"], max_nv=parsed_args["max_nv"],
                         recompute=parsed_args["recompute"])
end

main()
