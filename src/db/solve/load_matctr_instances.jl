function load_matctr_instance!(db::SQLite.DB, name, scenario, source_type, out)
    println("Loading matctr: ($name, $scenario)")
    instance_name = source_type == "RAWGO" ? "$(name)_$(scenario)" : "$(name)"
    mat_path = abspath(joinpath(out, "$(instance_name)_sdp_mat.txt"))
    ctr_path = abspath(joinpath(out, "$(instance_name)_sdp_ctr.txt"))
    isfile_mat = isfile(mat_path)
    isfile_ctr = isfile(ctr_path)
    query = ""
    if isfile_mat && isfile_ctr
        query = """
        UPDATE instances SET mat_path='$mat_path', ctr_path='$ctr_path'
        WHERE name = '$name' AND scenario = $scenario
        """
    elseif  !isfile_mat || !isfile_ctr
        if isfile_mat
            println("No ctr file found.")
            query = """
            UPDATE instances SET mat_path='$mat_path'
            WHERE name = '$name' AND scenario = $scenario
            """
        elseif isfile_ctr
            println("No mat file found.")
            query = """
            UPDATE instances SET ctr_path = '$ctr_path'
            WHERE name = '$name' AND scenario = $scenario
            """
        else
            println("No ctr or mat file found.")
            return
        end
    end
    println(query)
    execute_query(db, query)
end

function load_matctr_instances!(db::SQLite.DB; out, recompute=false, subset=nothing, min_nv=typemin(Int), max_nv=typemax(Int))
    query = "SELECT name, scenario, source_type FROM instances WHERE nbus >= $min_nv AND nbus <= $max_nv"
    if !recompute
        query *= " AND mat_path IS NULL OR ctr_path IS NULL"
    end
    if !isnothing(subset)
        query *= " AND id IN ($(join(subset, ',')))"
    end
    results = DBInterface.execute(db, query) |> DataFrame
    println("Loading matctr paths: out=$out, recompute=$recompute")
    println("subset\n$subset\nend subset")
    load_matctr_instance_function!(row) = load_matctr_instance_dfrow!(db, row[:name], row[:scenario], row[:source_type], out)
    load_matctr_instance_function!.(eachrow(results))
end
