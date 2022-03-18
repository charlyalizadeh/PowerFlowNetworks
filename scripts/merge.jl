include("../src/PowerFlowNetworks.jl")
using .PowerFlowNetworks
using SQLite
using ArgParse
using JSON


ArgParse.parse_item(::Type{Vector{String}}, x::AbstractString) = split(x, ",")
ArgParse.parse_item(::Type{Vector{Int}}, x::AbstractString) = parse.(Int, split(x, ","))

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
            default = "clique_nv_up"
        "--kwargs_path"
            help = "Julia file containing a dict named `merge_kwargs` containing the keyword arguments of the merge."
            arg_type = String
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
    include("../$(parsed_args["kwargs_path"])")
    db = SQLite.DB(parsed_args["dbpath"])
    if "sliwak" in parsed_args["heuristic"]
        error("Sliwak merge not implemented yet. (I need to get the coefficients of the merge for every instance)")
    end
    merge_decompositions!(db;
                          heuristic=parsed_args["heuristic"],
                          heuristic_switch=parsed_args["heuristic_switch"],
                          treshold_name=parsed_args["treshold_name"],
                          merge_kwargs=merge_kwargs,
                          min_nv=parsed_args["min_nv"],
                          max_nv=parsed_args["max_nv"])
end

main()
