function export_matpowerm_instance!(db::SQLite.DB, export_dir, name, scenario, source_type, source_path, pfn_path)
    println("Exporting instance to MATPOWERM file: ($name, $scenario)")
    export_path = ""
    if source_type == "MATPOWERM"
        export_path = joinpath(export_dir, basename(source_path))
        cp(source_path, export_path; force=true)
    else
        network = ismissing(pfn_path) ? PowerFlowNetwork(source_path, source_type) : deserialize(pfn_path)
        export_path = joinpath(export_dir, "$(name)_$(scenario).m")
        write_pfn(export_path, network)
    end
    query = "UPDATE instances SET matpowerm_path = '$export_path' WHERE name = '$name' AND scenario = $scenario"
    execute_set_immediate(db, query)
end

function export_matpowerm_instance_dfrow!(db::SQLite.DB, export_dir, row)
    export_matpowerm_instance!(db, export_dir, row[:name], row[:scenario], row[:source_type], row[:source_path], row[:pfn_path])
end

function export_matpowerm_instances!(db::SQLite.DB; min_nv, max_nv, export_dir, recompute=false, subset=nothing)
    !isdir(export_dir) && mkpath(export_dir)
    query = "SELECT name, scenario, source_type, source_path, pfn_path FROM instances WHERE nbus >= $min_nv AND nbus <= $max_nv"
    if !recompute
        query *= " AND matpowerm_path IS NULL"
    end
    if !isnothing(subset)
        query *= " AND id IN ($(join(subset, ',')))"
    end
    results = DBInterface.execute(db, query) |> DataFrame
    println("Exporting instance to MATPOWERM file: recompute=$recompute")
    println("subset\n$subset\nend subset")
    export_function!(row) = export_matpowerm_instance_dfrow!(db, export_dir, row)
    export_function!.(eachrow(results[!, [:name, :scenario, :source_type, :source_path, :pfn_path]]))
end
