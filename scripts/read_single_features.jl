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
        "--recompute"
            help = "Wether to recompute the basic features if they're already not NULL in the database."
            default = false
            action = :store_true
        "--feature_names"
            help = "Feature(s) name(s) to compute"
            required = true
            arg_type = Vector{String}
    end
    return parse_args(s)
end

function main()
    parsed_args = parse_commandline()
    db = SQLite.DB(parsed_args["dbpath"])
    save_single_features_instances!(db;
                                    feature_name=parsed_args["feature_names"],
                                    min_nv=parsed_args["min_nv"],
                                    max_nv=parsed_args["max_nv"],
                                    recompute=parsed_args["recompute"])
end

main()
