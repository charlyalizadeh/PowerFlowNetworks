function save_basic_features_instance!(db::SQLite.DB, name, scenario, source_type, source_path)
    println("Saving features: $name scenario $scenario")
    _nbus = nbus(source_path, source_type)
    _nbranch_unique = nbranch(source_path, source_type; distinct_pair=true)
    _nbranch = nbranch(source_path, source_type)
    _ngen = ngen(source_path, source_type)
    query = """
    UPDATE instances
    SET nbus = $_nbus, nbranch_unique = $_nbranch_unique, nbranch = $_nbranch, ngen = $_ngen
    WHERE name = '$name' AND scenario = $scenario;
    """
    DBInterface.execute(db, query)
end

function save_basic_features_instance_dfrow!(db::SQLite.DB, row)
    save_basic_features_instance!(db, row[:name], row[:scenario], row[:source_type], row[:source_path])
end

function save_basic_features_instances!(db::SQLite.DB; recompute=false, subset=nothing)
    query = "SELECT name, scenario, source_type, source_path FROM instances"
    if !recompute
        query *= " WHERE nbus IS NULL OR nbranch_unique IS NULL OR nbranch IS NULL OR ngen IS NULL"
    end
    if !isnothing(subset)
        subset = ["('$(s[1])', $(s[2]))" for s in subset]
        query *= " AND (name, scenario) IN ($(join(subset, ',')))"
    end
    results = DBInterface.execute(db, query) |> DataFrame
    save_function!(row) = save_basic_features_instance_dfrow!(db, row)
    save_function!.(eachrow(results[!, [:name, :scenario, :source_type, :source_path]]))
end
