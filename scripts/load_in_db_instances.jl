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
        "--indirs_rawgo"
            help = "Directory/ies containing the RAWGO networks."
            arg_type = Vector{String}
            default = readdir("data/RAWGO"; join=true)
        "--indirs_matpowerm"
            help = "Directory/ies containing the MATPOWERM networks."
            arg_type = Vector{String}
            default = ["data/MATPOWERM"]
    end
    return parse_args(s)
end

function main()
    parsed_args = parse_commandline()
    indirs_rawgo = parsed_args["indirs_rawgo"]
    indirs_matpowerm = parsed_args["indirs_matpowerm"]
    dbpath = parsed_args["dbpath"]
    db = SQLite.DB(dbpath)
    load_in_db_instances!(db, indirs_rawgo, indirs_matpowerm)
end

main()
