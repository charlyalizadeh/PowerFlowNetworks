function load_rawgo_instance!(db::SQLite.DB, path::AbstractString)
    date = Dates.now()
    name = splitdir(path)[end]
    scenarios = readdir(path)
    @info "Loading $(name)"
    for scenario in scenarios
        !isdir(joinpath(path, scenario)) && continue
        scenario_nb = parse(Int, scenario[10:end])
        source_path = abspath(joinpath(path, scenario))
        if !isfile(joinpath(source_path, "case.json")) && !isfile(joinpath(source_path, "case.rop"))
            @warn "No cost file found for ($name, $scenario_nb), not loaded in the database."
            continue
        end
        @info "  $(scenario_nb)"
        try
            load_in_db_instance!(db, name, scenario_nb, source_path, "RAWGO", date)
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
    source_type = "MATPOWERM"
    @info "Loading $(name)"
    try
        load_in_db_instance!(db, name, scenario_nb, source_path, source_type, date)
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
            !startswith(basename(f), "case") && continue
            load_matpower_mat_instance!(db, f)
        end
    end
end

function clean_dirs(dirs; verbose=true)
    cleaned_dirs = [d for d in dirs if isdir(d)]
    if length(cleaned_dirs) < length(dirs)
        @warn "$(setdiff(dirs, cleaned_dirs)) are not valid directory/ies (skipped)."
    end
    return cleaned_dirs
end

function load_in_db_instances!(db::SQLite.DB, indirs_rawgo, indirs_matpowerm)
    tables = ["instances", "decompositions", "mergers", "combinations", "solve_results"]
    isdb = isfile(db.file)
    if any(map(x -> !(x in SQLite.tables(db)[:name]), tables))
        db = setup_db(db.file)
    end
    indirs_rawgo = clean_dirs(indirs_rawgo)
    indirs_matpowerm = clean_dirs(indirs_matpowerm)
    load_matpower_mat_instances!(db, indirs_matpowerm)
    load_rawgo_instances!(db, indirs_rawgo)
end
