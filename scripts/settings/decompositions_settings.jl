decompositions_settings = Dict(setting_name => ArgParseSettings() for setting_name in ["generate", "merge", "combine", "interpolate", "solve", "delete_duplicates", "export_to_gnndata", "check_is_cholesky", "set_treshold_solving_time"])
for key in keys(decompositions_settings)
    decompositions_settings[key].error_on_conflict = false
end

@add_arg_table decompositions_settings["generate"] begin
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
        default = "data/graphs_serialized/"
    "--preprocess_path"
        help = "TOML file containing the preprocess option."
        default = "configs/preprocess.toml"
    "--preprocess_key"
        help = "Key corresonding to the section name in the preprocess toml file."
    "--kwargs_path"
        help = "TOML config file containing the configuration for the values for the `chordal_extension_kwargs` dictionary."
        arg_type = String
        default = "configs/chordal_extension.toml"
    "--kwargs_key"
        help = "Key corresponding to the section name in the chordal extension kwargs toml file."
        arg_type = String
        default = "default"
end
@add_arg_table decompositions_settings["merge"] begin
    "--heuristic"
        help = "Algorithm(s) used for the chordal extension."
        arg_type = Vector{String}
        default = ["molzahn"]
    "--heuristic_switch"
        help = "Iteration(s) when to switch the heuristic."
        arg_type = Vector{Int}
        default = [0]
    "--treshold_name"
        help = "Name of the treshold used to stop the merge."
        arg_type = String
        default = "clique_nv_up"
    "--kwargs_path"
        help = ".toml config files containing the configuration for the values for the `merge_kwargs` dictionary."
        arg_type = String
        default = "configs/merge.toml"
    "--kwargs_key"
        help = "Key corresponding to the section name in the .toml merge config files."
        arg_type = String
        default = "default"
end
@add_arg_table decompositions_settings["combine"] begin
    "--how"
        help = "Method used to combine the decompositions."
        arg_type = String
        default = "vertices_intersect"
    "--extension_alg"
        help = "Extension algorithm used in case the combination is not chordal."
        arg_type = String
        default = "cholesky"
    "--percent_max"
        help = "Percent of the cholesky time the decompositions must be under to be combined."
        arg_type = Float64
        default = 0.5
end
@add_arg_table decompositions_settings["interpolate"] begin
    "--how"
        help = "Method used to interpolate the decompositions."
        arg_type = String
        default = "vertices"
    "--nb_per_interpolation"
        help = "Number of decompositions used per interpolation."
        arg_type = Int
        default = 2
end
@add_arg_table decompositions_settings["solve"] begin
    "--cholesky"
        help = "Wether to solve only default Cholesky decomposition."
        default = false
        action = :store_true
end
@add_arg_table decompositions_settings["delete_duplicates"] begin
end
@add_arg_table decompositions_settings["export_to_gnndata"] begin
    "--out"
        help = "Directory where to the gnndata."
        default = "data/gnndata"
end
@add_arg_table decompositions_settings["check_is_cholesky"] begin
end
@add_arg_table decompositions_settings["set_treshold_solving_time"] begin
    "--treshold"
        help = "Set the limit for the solving times to cholesky_time * treshold."
        arg_type = Int
        default = 2
end
