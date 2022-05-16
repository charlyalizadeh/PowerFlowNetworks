using ArgParse
using TOML


general_settings = Dict(setting_name => ArgParseSettings() for setting_name in ["db", "nbus_limit", "recompute", "mpi", "toml_config"])
for key in keys(general_settings)
    general_settings[key].error_on_conflict = false
end

ArgParse.parse_item(::Type{Vector{String}}, x::AbstractString) = split(x, ",")
ArgParse.parse_item(::Type{Union{Int, Nothing}}, x::AbstractString) = x == "nothing" ? nothing : parse(Int, x)

@add_arg_table general_settings["db"] begin
    "--dbpath", "-p"
        help = "Path of the sqlite database file."
        default = "data/PowerFlowNetworks.sqlite"
end

@add_arg_table general_settings["nbus_limit"] begin
    "--min_nv"
        help = "Minimum number of vertices a network has to have to be processed."
        arg_type = Int
        default = typemin(Int)
    "--max_nv"
        help = "Maximum number of vertices a network has to have to be processed."
        arg_type = Int
        default = typemax(Int)
end

@add_arg_table general_settings["recompute"] begin
    "--recompute"
        help = "Wether to recompute the process if already computed."
        default = false
        action = :store_true
end

@add_arg_table general_settings["mpi"] begin
    "--mpi"
        help = "If set, uses MPI to parallelize the process."
        arg_type = Bool
        default = false
        action = :store_true
    "--log_dir"
        help = "The directory where to store the logs of the process."
        default = ".log"
        arg_type = String
end

@add_arg_table general_settings["toml_config"] begin
    "--toml_config"
        help = "If set, uses the configuration in `toml_config_path` at key `toml_config_key`. (TOML options overloads the others)"
        arg_type = Bool
        default = false
        action = :store_true
    "--toml_config_path"
        help = "Path of the TOML configuration file. (Ignored it `--toml_config` is not set)"
        arg_type = String
        default = "configs/defaults.toml"
    "--toml_config_key"
        help = "Key inside the TOML configuration file `--toml_config_file`. (Ignored it `--toml_config` is not set)"
        arg_type = String
end

function import_general_settings!(settings::ArgParseSettings, general_settings_keys)
    settings.error_on_conflict = false
    for key in general_settings_keys
        import_settings(settings, general_settings[key])
    end
end

strkey_to_symkey(args, subset=keys(args)) = Dict(Symbol(k) => v for (k, v) in args if k in subset)

overwrite_toml!(dict, toml_config_path, toml_config_key) = merge!(dict, TOML.parsefile(toml_config_path)[toml_config_key])
