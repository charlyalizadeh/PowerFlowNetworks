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
            arg_type = String
        "--process_type"
            help = "The type of process to execute."
            arg_type = String
        "--log_dir"
            help = "The directory where to store the logs of the process."
            arg_type = String
        "--config_key"
            help = "Key corresponding to the keyword arguments used in this process."
            arg_type = String
        "--config_path"
            help = "Path to a julia file containing a dict with the keyword arguments."
            arg_type = String
            default = "data/configs/kwargs.jl"
    end
    return parse_args(s)
end

function main()
    parsed_args = parse_commandline()
    db = SQLite.DB(parsed_args["dbpath"])
    include("../$(parsed_args["config_path"])")
    execute_process_mpi(db, parsed_args["process_type"], parsed_args["log_dir"];
                        process_kwargs[parsed_args["config_key"]]...)
end

main()
