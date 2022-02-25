include("../src/PowerFlowNetworks.jl")
using .PowerFlowNetworks
using SQLite
using Dates
using DataFrames

rawgo_dirs = readdir("data/RAWGO"; join=true)

function load_rawgo_instance!(db::SQLite.DB, path::AbstractString)
    date = Dates.now()
    name = splitdir(path)[end]
    scenarios = readdir(path)
    @info "Loading $(name)"
    for scenario in scenarios
        !isdir(joinpath(path, scenario)) && continue
        scenario_nb = parse(Int, scenario[10:end])
        source_path = abspath(joinpath(path, scenario, "case.raw"))
        @info "  $(scenario_nb)"
        try
            load_instance!(db, name, scenario_nb, source_path, "RAWGO", date)
        catch SQLiteException
            @warn "$(name) scenario $(scenario_nb) already in the database. Loading ignored."
        end
    end
end

function load_rawgo_instances!(db::SQLite.DB, dirs=rawgo_dirs)
    for dir in rawgo_dirs
        for instance_dir in readdir(dir; join=true)
            !isdir(instance_dir) && continue
            load_rawgo_instance!(db, instance_dir)
        end
    end
end
