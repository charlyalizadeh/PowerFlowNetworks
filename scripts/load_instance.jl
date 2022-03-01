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
            default = "data/PowerFlowNetwork.sqlite"
        "--indirs_rawgo"
            help = "Directory/ies containing the RAWGO networks."
            arg_type = Vector{String}
            default = readdir("data/RAWGO"; join=true)
        "--indirs_matpowermat"
            help = "Directory/ies containing the MATPOWER-MAT networks."
            arg_type = Vector{String}
            default = ["data/MATPOWER"]
    end
    return parse_args(s)
end

function clean_dirs(dirs; verbose=true)
    cleaned_dirs = [d for d in dirs if isdir(d)]
    if length(cleaned_dirs) < length(dirs)
        @warn "$(setdiff(dirs, cleaned_dirs)) are not valid directory/ies (skipped)."
    end
    return cleaned_dirs
end

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
        catch e
            if isa(e, SQLiteException) && e.msg == "UNIQUE constraint failed: instances.name, instances.scenario"
                @warn "$(name) scenario $(scenario_nb) already in the database. Loading ignored."
            else
                rethrow()
            end
        end
    end
end

function load_rawgo_instances!(db::SQLite.DB, dirs)
    for dir in dirs
        for instance_dir in readdir(dir; join=true)
            !isdir(instance_dir) && continue
            load_rawgo_instance!(db, instance_dir)
        end
    end
end

function load_matpower_mat_instance!(db::SQLite.DB, path::AbstractString)
    date = Dates.now()
    name = splitext(basename(path))[end - 1]
    scenario_nb = 0
    source_path = abspath(path)
    source_type = "MATPOWER-MAT"
    @info "Loading $(name)"
    try
        load_instance!(db, name, scenario_nb, source_path, source_type, date)
    catch e
        if isa(e, SQLiteException) && e.msg == "UNIQUE constraint failed: instances.name, instances.scenario"
            @warn "$(name) scenario $(scenario_nb) already in the database. Loading ignored."
        else
            rethrow()
        end
    end
end

function load_matpower_mat_instances!(db::SQLite.DB, dirs)
    for dir in dirs
        files = readdir(dir; join=true)
        for f in files
            load_matpower_mat_instance!(db, f)
        end
    end
end

function main()
    parsed_args = parse_commandline()
    indirs_rawgo = clean_dirs(parsed_args["indirs_rawgo"])
    indirs_matpowermat = clean_dirs(parsed_args["indirs_matpowermat"])
    dbpath = parsed_args["dbpath"]
    isdb = isfile(dbpath)
    db = SQLite.DB(dbpath)
    tables = ["instances", "decompositions", "mergers", "combinations", "solve_results"]
    if !isdb || any(map(x -> !(x in SQLite.tables(db)), tables))
        db = setup_db(dbpath)
    end
    load_matpower_mat_instances!(db, indirs_matpowermat)
    load_rawgo_instances!(db, indirs_rawgo)
end

main()
