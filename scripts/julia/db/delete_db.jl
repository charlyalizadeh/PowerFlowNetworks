function delete_db()
    to_delete = [
        "data/PowerFlowNetworks.sqlite",
        "data/cliquetrees",
        "data/cliques",
        "data/networks_serialized",
        "data/graphs_serialized",
        "data/matpowerm_instance"
    ]
    for f in to_delete
        rm(f; force=true, recursive=true)
    end
end

delete_db()
