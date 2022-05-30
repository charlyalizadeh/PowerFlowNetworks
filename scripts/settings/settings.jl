include("general_settings.jl")
include("instances_settings.jl")
include("decompositions_settings.jl")
include("db_settings.jl")

general_settings_map = Dict(
        "instances" => Dict(
            "load_in_db" => ["db", "toml_config"],
            "save_basic_features" => ["db", "recompute", "mpi", "toml_config"],
            "save_features" => ["db", "recompute", "mpi", "toml_config"],
            "serialize" => ["db", "nbus_limit", "recompute", "mpi", "toml_config"],
            "load_matctr" => ["db", "toml_config"]
        ),
        "decompositions" => Dict(
            "generate" => ["db", "nbus_limit", "mpi", "toml_config"],
            "merge" => ["db", "nbus_limit", "recompute", "mpi", "toml_config"],
            "combine" => ["db"],
            "solve" => ["db", "nbus_limit", "recompute", "mpi"],
            "delete_duplicates" => ["db", "mpi"],
            "export_to_gnndata" => ["db"]
        ),
        "db" => Dict(
            "check_sanity" => ["db", "nbus_limit", "mpi", "toml_config"],
            "delete" => ["db"]
        )
)
settings = Dict(
        "instances" => instances_settings,
        "decompositions" => decompositions_settings,
        "db" => db_settings
)
for (subject, settings_dict) in general_settings_map
    for (command, keys_array) in settings_dict
        import_general_settings!(settings[subject][command], keys_array)
    end
end
