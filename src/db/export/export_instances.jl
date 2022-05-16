function export_instance!(db::SQLite.DB, to, export_dir, name, scenario, source_type, source_path, network_path)
    println("Exporting instance to $(to) file: ($name, $scenario)")
    network = ismissing(network_path) ? PowerFlowNetwork(source_path, source_type) : load_network(network_path)
    export_path = joinpath(export_dir, "$(name)_$(scenario).$(export_extension[to])")
    export_network(export_path, network, to)
    query = "UPDATE instances SET $(to)_path = '$export_path' WHERE name = '$name' AND scenario = $scenario"
    execute_query(db, query)
end

function export_instances!(db::SQLite.DB; to, min_nv, max_nv, export_dir, recompute=false, subset=nothing)
    export_dir = joinpath(export_dir, to)
    !isdir(export_dir) && mkpath(export_dir)
    colname = "$(to)_path"
    if !has_column(db, "instances", colname)
        execute_query_once(db, "ALTER TABLE instances ADD $colname TEXT")
    end
    query = "SELECT name, scenario, source_type, source_path, network_path FROM instances WHERE nbus >= $min_nv AND nbus <= $max_nv"
    if !recompute
        query *= " AND $colname IS NULL"
    end
    if !isnothing(subset)
        query *= " AND id IN ($(join(subset, ',')))"
    end
    results = DBInterface.execute(db, query) |> DataFrame
    println("Exporting instance to MATPOWERM file: recompute=$recompute, min_nv=$min_nv, max_nv=$max_nv, export_dir=$export_dir")
    println("subset\n$subset\nend subset")
    export_function!(row) = export_instance!(db, to, export_dir, row[:name], row[:scenario], row[:source_type], row[:source_path], row[:network_path])
    export_function!.(eachrow(results))
end
