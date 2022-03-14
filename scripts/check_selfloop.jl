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
        "--table"
            help = "The table from which to extract the graphs (either \"instances\" or \"decompositions\")"
    end
    return parse_args(s)
end

function main()
    parsed_args = parse_commandline()
    db = SQLite.DB(parsed_args["dbpath"])
    check_selfloops(db; min_nv=parsed_args["min_nv"], max_nv=parsed_args["max_nv"], table=parsed_args["table"])
end

main()
