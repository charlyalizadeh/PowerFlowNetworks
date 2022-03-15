function has_opf_tables(db::SQLite.DB)
    tables = ["instances", "decompositions", "merges", "combinations"]
    return all(map(in(SQLite.tables(db)[:name]), tables))
end

function count_missing_columns(db::SQLite.DB, table, columns)
    query = """
    SELECT $(join(columns, ',')) FROM $table 
    WHERE $(join(columns, " IS NULL OR ")) IS NULL
    """
    results = DBInterface.execute(db, query) |> DataFrame
    states = Dict(zip(names(results), map(x -> sum(ismissing.(x)), eachcol(results))))
    states["total"] = nrow(results)
    return states
end

function table_count(db::SQLite.DB, table)
    query = "SELECT COUNT(*) FROM $table"
    results = DBInterface.execute(db, query) |> DataFrame
    return results[1, Symbol("COUNT(*)")][1]
end

nb_instances(db::SQLite.DB) = table_count(db, "instances")
nb_decompositions(db::SQLite.DB) = table_count(db, "decompositions")

function get_table_ids(db::SQLite.DB, table)
    query = "SELECT id FROM $table"
    results = DBInterface.execute(db, query) |> DataFrame
    return results[!, :id]
end
