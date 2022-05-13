function db_to_csv(db, out; tables=["instances", "decompositions"])
    !isdir(out) && mkpath(out)
    for table in tables
        table_df = DBInterface.execute(db, "SELECT * FROM $table") |> DataFrame
        CSV.write(joinpath(out, "$table.csv"), table_df)
    end
end

function decomposition_to_gnndata(row, graph, out)
    graph = loadgraph(row[:graph_path])
    edges = [[e.src, e.dst] for e in Graphs.edges(graph)]
    open(out, "w") do io
        JSON.print(io, edges)
    end
end

function _row_to_dict(row)
    return Dict(names(row) .=> values(row))
end

function db_to_gnndata(db, out)
    !isdir(out) && mkpath(out)
    instances_path = joinpath(out, "instances")
    decompositions_path = joinpath(out, "decompositions")
    mkpath(instances_path)
    mkpath(decompositions_path)
    instances = DBInterface.execute(db, "SELECT * FROM instances WHERE pfn_path IS NOT NULL AND graph_path IS NOT NULL") |> DataFrame
    decompositions = DBInterface.execute(db, "SELECT * FROM decompositions") |> DataFrame
    networks = Dict("$(row[:name])_$(row[:scenario])" => deserialize(row[:pfn_path]) for row in eachrow(instances))
    graphs = Dict(row[:id] => loadgraph(row[:graph_path]) for row in eachrow(instances))    
    # Saving instances
    for (name, network) in networks
        # nodes
        bus_dict = Dict(network.bus[!, :ID] .=> _row_to_dict.(eachrow(network.bus[!, Not(:ID)])))
        gen_dict = Dict(network.gen[!, :ID] .=> _row_to_dict.(eachrow(network.gen[!, Not(:ID)])))
        gencost_dict = Dict(network.gencost[!, :ID] .=> _row_to_dict.(eachrow(network.gencost[!, Not(:ID)])))
        node_dict = merge(merge, bus_dict, gen_dict)
        node_dict = merge(merge, node_dict, gencost_dict)

        # edges
        edges = [[row[:SRC], row[:DST]] for row in eachrow(network.branch)]
        branch_dict = Dict(edges .=> _row_to_dict.(eachrow(network.branch[!, Not([:SRC, :DST])])))
        final_dict = Dict("nodes" => node_dict, "edges" => branch_dict)
        open(joinpath(instances_path, "$name.json"), "w") do io
            JSON.print(io, final_dict)
        end
    end

    # Saving decompositions
    to_ggnndata_function(row) = decomposition_to_gnndata(row, graphs[row[:origin_id]],
                                                         joinpath(decompositions_path, "$(row[:origin_name])_$(row[:origin_scenario])_$(row[:uuid]).json"))
    to_ggnndata_function.(eachrow(decompositions))
end
