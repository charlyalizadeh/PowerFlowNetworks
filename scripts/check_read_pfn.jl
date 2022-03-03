include("../src/PowerFlowNetworks.jl")
using .PowerFlowNetworks
using SQLite
using Dates
using DataFrames
using ArgParse

ArgParse.parse_item(::Type{Vector{String}}, x::AbstractString) = split(x, ",")

function parse_commandline()
    s = ArgParseSettings()
    @add_arg_table s begin
        "--dbpath", "-p"
            help = "Path of the sqlite database file."
            default = "data/PowerFlowNetworks.sqlite"
        "--source_type"
            help = "The source types to check."
            default = ["RAWGO", "MATPOWER-M"]
            arg_type = Vector{String}
        "--rethrow"
            help = "Wether to rethrow the errors. (will stop the execution)"
            default = false
            action = :store_true
        "--one"
            help = "Check only one instance."
            default = false
            action = :store_true
        "--name"
            help = "Name of the instance to test. (Only used if `--one` is set)"
            default = ""
        "--scenario"
            help = "Scenario of the instance to test. (Only used if `--one` is set)"
            default = ""
    end
    return parse_args(s)
end

function check_network(name, scenario, source_path, source_type; rethrow_error)
    try
        network = PowerFlowNetwork(source_path, source_type)
    catch e
        println("$name scenario $scenario throwed: $e \n  source_path: $source_path\n  source_type: $source_type")
        rethrow_error && rethrow()
    end
end

check_network_dfrow(row; rethrow_error) = check_network(row[:name], row[:scenario], row[:source_path], row[:source_type]; rethrow_error=rethrow_error)

function check_networks(db, source_type; rethrow_error)
    source_type = map(s -> "'$s'", source_type)
    query = "SELECT name, scenario, source_path, source_type FROM instances WHERE source_type IN ($(join(source_type, ',')))"
    results = DBInterface.execute(db, query) |> DataFrame
    func(row) = check_network_dfrow(row; rethrow_error=rethrow_error)
    func.(eachrow(results[!, [:name, :scenario, :source_path, :source_type]]))
end

function main()
    parsed_args = parse_commandline()
    db = SQLite.DB(parsed_args["dbpath"])
    if parsed_args["one"]
        name, scenario = parsed_args["name"], parsed_args["scenario"]
        query = "SELECT source_path, source_type FROM instances WHERE name = '$name' AND scenario = $scenario"
        result = DBInterface.execute(db, query) |> DataFrame
        source_path, source_type = result[1, :source_path], result[1, :source_type]
        check_network(name, scenario, source_path, source_type; rethrow_error=true)
    else
        check_networks(db, parsed_args["source_type"]; rethrow_error=parsed_args["rethrow"])
    end
end

main()
