function has_opf_tables(db::SQLite.DB)
    tables = ["instances", "decompositions", "merges", "combinations"]
    return all(map(in(SQLite.tables(db)[:name]), tables))
end

function has_column(db::SQLite.DB, table, column)
    query = """
    WITH tables AS (SELECT name tableName
    FROM sqlite_master WHERE type = 'table' AND tableName NOT LIKE 'sqlite_%' AND tableName = '$table')
    SELECT fields.name, fields.type, tableName
    FROM tables CROSS JOIN pragma_table_info(tables.tableName) fields
    """
    results = DBInterface.execute(db, query) |> DataFrames
    return column in results[!, :name]
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

function get_cholesky_times(db::SQLite.DB)
    query = "SELECT origin_name, origin_scenario, solving_time FROM decompositions WHERE solving_time IS NOT NULL AND extension_alg = 'cholesky' AND preprocess_key = '0'"
    results = DBInterface.execute(db, query) |> DataFrame
    return Dict("$(row[:origin_name])_$(row[:origin_scenario])" => row[:solving_time] for row in eachrow(results))
end

