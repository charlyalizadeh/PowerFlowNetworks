function has_opf_tables(db::SQLite.DB)
    tables = ["instances", "decompositions", "merges", "combinations"]
    return all(map(in(SQLite.tables(db)[:name]), tables))
end

function state_columns(db::SQLite.DB, table, columns)
    query = """
    SELECT $(join(columns, ',')) FROM $table 
    WHERE $(join(columns, " IS NULL OR ")) IS NULL
    """
    results = DBInterface.execute(db, query) |> DataFrame
    states = Dict(zip(names(results), map(x -> sum(ismissing.(x)), eachcol(results))))
    states["total"] = nrow(results)
    return states
end
