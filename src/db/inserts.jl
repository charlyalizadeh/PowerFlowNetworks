function load_instance!(db::SQLite.DB,
                        name::AbstractString, scenario::Int,
                        source_path::AbstractString, source_type::AbstractString,
                        date::DateTime)
    query = """
    INSERT INTO instances(name, scenario, source_path, source_type, date) 
    VALUES('$name', $scenario, '$source_path', '$source_type', '$date')
    """
    DBInterface.execute(db, query)
end
