include("../src/PowerFlowNetworks.jl")
include("settings/settings.jl")
using .PowerFlowNetworks
using SQLite
using ArgParse

# Functions
single_process_functions = Dict(
        "instances" => Dict(
            "load_in_db" => load_in_db_instances!,
            "save_basic_features" => save_basic_features_instances!,
            "save_features" => save_features_instances!,
            "serialize" => serialize_instances!,
            "load_matctr" => load_matctr_instances!
            #"explore" => explore_instances
        ),
        "decompositions" => Dict(
            "generate" => generate_decompositions!,
            "merge" => merge_decompositions!,
            "combine" => combine_decompositions!,
            "interpolate" => interpolate_decompositions!,
            "solve" => solve_decompositions!,
            "delete_duplicates" => delete_duplicates!,
            "export_to_gnndata" => export_db_to_gnndata,
            "check_is_cholesky" => check_is_cholesky_decompositions!,
            "set_treshold_solving_time" => set_treshold_solving_time_decompositions!
        ),
        "db" => Dict(
            "check_sanity" => check_sanity,
            "delete" => delete_db,
        )
)
specific_mpi_functions = Dict(
    "instances" => Dict(),
    "decompositions" => Dict(),
    "db" => Dict("check_sanity" => check_sanity_mpi)
)
no_use_mpi = [("db","delete")]
# Kwargs
args_to_keep = Dict(
        "instances" => Dict(
            "load_in_db" => ["indirs_rawgo", "indirs_matpowerm"],
            "save_basic_features" => ["recompute"],
            "save_features" => ["min_nv", "max_nv", "recompute"],
            "serialize" => ["min_nv", "max_nv", "recompute", "networks_path", "graphs_path"],
            "load_matctr" => ["min_nv", "max_nv", "out"],
            "explore" => ["min_nv", "max_nv", "out"]
        ),
        "decompositions" => Dict(
            "generate" => ["min_nv", "max_nv", "extension_alg", "cliques_path", "cliquetrees_path", "graphs_path", "preprocess_path", "preprocess_key"],
            "merge" => ["min_nv", "max_nv", "heuristic", "heuristic_switch", "treshold_name", "kwargs_path", "kwargs_key"],
            "combine" => ["percent_max", "how", "extension_alg"],
            "interpolate" => ["how", "nb_per_interpolation"],
            "solve" => ["min_nv", "max_nv", "recompute", "cholesky"],
            "delete_duplicates" => [],
            "export_to_gnndata" => ["out"],
            "check_is_cholesky" => [],
            "set_treshold_solving_time" => ["treshold"]
        ),
        "db" => Dict(
            "check_sanity" => ["min_nv", "max_nv", "table", "check"],
            "delete" => []
        )
)

function parse_commandline(subject, command)
    return parse_args(s)
end

function main()
    subject, command = split(ARGS[1], ":")
    deleteat!(ARGS, 1)
    args = parse_args(settings[subject][command])
    if haskey(args, "toml_config") && args["toml_config"]
        args = overwrite_toml(args, args["toml_config_path"], args["toml_config_key"])
    end
    db = SQLite.DB(args["dbpath"])
    kwargs = strkey_to_symkey(args, args_to_keep[subject][command])
    if haskey(args, "mpi") && args["mpi"] && !((subject, command) in no_use_mpi)
        if haskey(specific_mpi_functions[subject], command)
            specific_mpi_functions[subject][command](db, args["log_dir"]; kwargs...)
        else
            execute_process_mpi(db, "$(command)_$(subject)", args["log_dir"]; kwargs...)
        end
    else
        single_process_functions[subject][command](db; kwargs...)
    end
end

main()
