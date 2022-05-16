function get_config_toml(path::AbstractString; key_symbol=true)
    config_dict = TOML.parsefile(path)
    if key_symbol
        for key in keys(config_dict)
            config_dict[key] = Dict(Symbol(k) => v for (k, v) in config_dict[key])
        end
    end
    return config_dict
end
