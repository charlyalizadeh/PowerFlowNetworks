db_settings = Dict(setting_name => ArgParseSettings() for setting_name in ["check_read_network", "check_sanity", "delete"])
for key in keys(db_settings)
    db_settings[key].error_on_conflict = false
end

@add_arg_table db_settings["check_read_network"] begin
end
@add_arg_table db_settings["check_sanity"] begin
    "--check"
        help = "Name of the check to apply on the database."
        arg_type = String
    "--table"
        help = "Table on which to apply the sanity check."
        arg_type = String
end
@add_arg_table db_settings["delete"] begin
end
