include("../src/PowerFlowNetworks.jl")
using .PowerFlowNetworks
using SQLite
using ArgParse


ArgParse.parse_item(::Type{Vector{String}}, x::AbstractString) = split(x, ",")
ArgParse.parse_item(::Type{Union{Int, Nothing}}, x::AbstractString) = x == "nothing" ? nothing : parse(Int, x)

function parse_commandline()
    s = ArgParseSettings()
    @add_arg_table s begin
        "--dbpath", "-p"
            help = "Path of the sqlite database file."
            default = "data/PowerFlowNetworks.sqlite"
        "--min_nv"
            help = "Minimum number of vertices a network had to have to be processed."
            arg_type = Union{Int, Nothing}
            default = nothing
        "--max_nv"
            help = "Maximum number of vertices a network had to have to be processed."
            arg_type = Union{Int, Nothing}
            default = nothing
        "--checks"
            help = "Name of the checks to apply on the database."
            arg_type = Vector{String}
            default = ["chordality", "connectivity", "self_loops", "index_clique", "source_graph", "serialize_graph", "serialize_network", "basic_feature"]
    end
    return parse_args(s)
end

function main()
    parsed_args = parse_commandline()
    db = SQLite.DB(parsed_args["dbpath"])
    check_sanity(db, parsed_args["checks"];
                 min_nv=parsed_args["min_nv"], max_nv=parsed_args["max_nv"])
end

main()
