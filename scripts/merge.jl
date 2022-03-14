include("../src/PowerFlowNetworks.jl")
using .PowerFlowNetworks
using SQLite
using ArgParse
using JSON


ArgParse.parse_item(::Type{Vector{String}}, x::AbstractString) = split(x, ",")
ArgParse.parse_item(::Type{Vector{Int}}, x::AbstractString) = parse.(Int, split(x, ","))
ArgParse.parse_item(::Type{Dict}, x::AbstractString) = JSON.parse(x)

function parse_commandline()
    s = ArgParseSettings()
    @add_arg_table s begin
        "--dbpath", "-p"
            help = "Path of the sqlite database file"
            default = "data/PowerFlowNetworks.sqlite"
        "--heuristic"
            help = "Algorithm(s) used for the chordal extension"
            arg_type = Vector{String}
            default = ["molzahn"]
        "--heuristic_switch"
            help = "Iteration(s) when to switch the heuristic"
            arg_type = Vector{Int}
            default = [0]
        "--treshold_name"
            help = "Name of the treshold used to stop the merge"
            arg_type = String
            default = "cliques_nv_up"
        "--merge_kwargs"
            help = "Keyword arguments used in the merge algorithm"
            arg_type = Dict
            default = Dict("treshold_percent" => 0.1)
        "--min_nv"
            help = "Minimum number of vertices a network had to have to be processed."
            arg_type = Int
            default = typemin(Int)
        "--max_nv"
            help = "Maximum number of vertices a network had to have to be processed."
            arg_type = Int
            default = typemax(Int)
    end
    return parse_args(s)
end

function main()
    parsed_args = parse_commandline()
    db = SQLite.DB(parsed_args["dbpath"])
    if "sliwak" in parsed_args["heuristic"]
        error("Sliwak merge not implemented yet. (I need to get the coefficients of the merge for every instance)")
    end
    merge_decompositions!(db,
                          parsed_args["heuristic"],
                          parsed_args["heuristic_switch"],
                          parsed_args["treshold_name"],
                          parsed_args["merge_kwargs"],
                          min_nv=parsed_args["min_nv"],
                          max_nv=parsed_args["max_nv"])
end

main()
