instances_settings = Dict(setting_name => ArgParseSettings() for setting_name in ["load_in_db", "save_basic_features", "save_features", "serialize", "load_matctr", "explore"])
for key in keys(instances_settings)
    instances_settings[key].error_on_conflict = false
end

@add_arg_table instances_settings["load_in_db"] begin
    "--indirs_rawgo"
        help = "Directory/ies containing the RAWGO networks."
        arg_type = Vector{String}
        default = readdir("data/RAWGO"; join=true)
    "--indirs_matpowerm"
        help = "Directory/ies containing the MATPOWERM networks."
        arg_type = Vector{String}
        default = ["data/MATPOWERM"]
end
@add_arg_table instances_settings["save_basic_features"] begin
end
@add_arg_table instances_settings["save_features"] begin
end
@add_arg_table instances_settings["serialize"] begin
    "--networks_path"
        help = "Where to store the serialize networks."
        default = "data/networks_serialized/"
    "--graphs_path"
        help = "Where to store the graphs."
        default = "data/graphs_serialized/"
end
@add_arg_table instances_settings["load_matctr"] begin
    "--out"
        help = "Directory where the mat and ctr files are."
        default = "data/matctr"
end
@add_arg_table instances_settings["explore"] begin
    "--out"
        help = "Directory where to store the plots."
        default = "reports/plots"
end
