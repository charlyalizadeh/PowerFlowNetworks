function save_basic_features_instance!(db::SQLite.DB, name, scenario, source_type, source_path)
    println("Saving basic instance features: ($name, $scenario)")
    _nbus = nbus(source_path, source_type)
    _nbranch_unique = nbranch(source_path, source_type; distinct_pair=true)
    _nbranch = nbranch(source_path, source_type)
    _ngen = ngen(source_path, source_type)
    query = """
    UPDATE instances
    SET nbus = $_nbus, nbranch_unique = $_nbranch_unique, nbranch = $_nbranch, ngen = $_ngen
    WHERE name = '$name' AND scenario = $scenario;
    """
    execute_query(db, query)
end

function save_basic_features_instances!(db::SQLite.DB; recompute=false, subset=nothing, kwargs...)
    query = "SELECT name, scenario, source_type, source_path FROM instances"
    if !recompute
        query *= " WHERE (nbus IS NULL OR nbranch_unique IS NULL OR nbranch IS NULL OR ngen IS NULL)"
    end
    if !isnothing(subset)
        if !recompute
            query *= " AND id IN ($(join(subset, ',')))"
        else
            query *= " WHERE id IN ($(join(subset, ',')))"
        end
    end
    results = DBInterface.execute(db, query) |> DataFrame
    println("Saving basic instance features config: recompute=$recompute")
    println("subset\n$subset\nend subset")
    save_function!(row) = save_basic_features_instance!(db, row[:name], row[:scenario], row[:source_type], row[:source_path])
    save_function!.(eachrow(results))
end
