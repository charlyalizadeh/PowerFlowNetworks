function delete_db(db::SQLite.DB; kwargs...)
    data_path = dirname(db.file)
    println("Are you sure you want to delete the database ? y/N")
    answer = readline()
    if answer == "y"
        to_delete = [
            "$data_path/PowerFlowNetworks.sqlite",
            "$data_path/cliquetrees",
            "$data_path/cliques",
            "$data_path/networks_serialized",
            "$data_path/graphs_serialized",
            "$data_path/matpowerm_instance",
            "$data_path/gnndata",
            "$data_path/mosek_logs",
        ]
        for f in to_delete
            rm(f; force=true, recursive=true)
        end
    end
end
