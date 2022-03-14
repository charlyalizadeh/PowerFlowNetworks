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
        "--extension_alg"
            help = "Algorithm used for the chordal extension."
            default = "cholesky"
        "--cliques_path"
            help = "Directory where to store the cliques."
            default = "data/cliques"
        "--cliquetrees_path"
            help = "Directory where to store the cliquetrees."
            default = "data/cliquetrees"
        "--graphs_path"
            help = "Where to store the graphs."
            default = "data/graphs/"
        "--preprocess_path"
            help = "JSON file containing the preprocess option."
            default = "configs/preprocess_default.json"
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
    generate_decompositions!(db,
                             parsed_args["cliques_path"],
                             parsed_args["cliquetrees_path"],
                             parsed_args["graphs_path"],
                             parsed_args["extension_alg"],
                             parsed_args["preprocess_path"];
                             min_nv=parsed_args["min_nv"],
                             max_nv=parsed_args["max_nv"])
end

main()
