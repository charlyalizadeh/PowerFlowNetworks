using SQLite

function write_queries(db, path="queries/")
    for f in readdir(path; join=true)
        open(f, "r") do io
            query = read(io, String)
            try
                DBInterface.execute(db, query)
            catch e
                if !(isa(e, SQLiteException) && e.msg == "UNIQUE constraint failed: instances.name, instances.scenario")
                    rethrow()
                end
            end
        end
    end
end

db = SQLite.DB("data/PowerFlowNetworks.sqlite")
write_queries(db)
