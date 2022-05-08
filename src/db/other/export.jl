function db_to_csv(db, out; tables=["instances", "decompositions"])
    !isdir(out) && mkpath(out)
    for table in tables
        table_df = DBInterface.execute(db, "SELECT * FROM $table") |> DataFrame
        CSV.write(joinpath(out, "$table.csv"), table_df)
    end
end

function decomposition_to_gnndata(row, graph, out)
    graph = loadgraph(row[:graph_path])
    nv = nv(graph)
    edges = [[e.src, e.dst] for e in edges(graph)]
end

function db_to_gnndata(db, out)
    !isdir(out) && mkpath(out)
    instances = DBInterface.execute(db, "SELECT * FROM instances") |> DataFrame
    decompositions = DBInterface.execute(db, "SELECT * FROM decompositions") |> DataFrame
    networks = [deserialize(p) for p in instances[!, :pfn_path]]
    graphs = [loadgraph(g) for g in instances[!, :graph_path]]
    for network in networks
        bus_dict = Dict(network.bus[!, :ID] .=> network.bus[!, Not(:ID)])
        gen_dict = Dict(network.gen[!, :ID] .=> network.gen[!, Not(:ID)])
        branch_dict = Dict(network.branch[!, :ID] .=> network.branch[!, Not(:ID)])
        gencost_dict = Dict(network.gencost[!, :ID] .=> network.gencost[!, Not(:ID)])
        print(bus_dict)
    end
end
