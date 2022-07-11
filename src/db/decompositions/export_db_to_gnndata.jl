function db_to_csv(db, out; tables=["instances", "decompositions"])
    !isdir(out) && mkpath(out)
    for table in tables
        table_df = DBInterface.execute(db, "SELECT * FROM $table") |> DataFrame
        CSV.write(joinpath(out, "$table.csv"), table_df)
    end
end

function _row_to_dict(row)
    return Dict(names(row) .=> values(row))
end

function get_dec_type(row)
    if row[:extension_alg] == "cholesky" && row[:nb_added_edge_dec] == "0"
        return "cholesky"
    elseif row[:extension_alg] == "merge"
        query = "SELECT treshold_percent FROM merges WHERE out_id = $(row[:id])"
        treshold_percent = DBInterface.execute(query) |> DataFrame
        treshold_percent = treshold_percent[0, :treshold_percent]
        return "merge:$(treshold_percent)"
    else
        return "$(row[:extension_alg]):$(row[:preprocess_key])"
    end
end

function export_db_to_gnndata(db; out)
    println("Exporting to $out")
    !isdir(out) && mkpath(out)
    decompositions = DBInterface.execute(db, "SELECT * FROM decompositions WHERE solving_time IS NOT NULL") |> DataFrame
    decompositions_names = unique(["$(row[:origin_name])_$(row[:origin_scenario])" for row in eachrow(decompositions)])
    instances = DBInterface.execute(db, "SELECT * FROM instances WHERE network_path IS NOT NULL AND graph_path IS NOT NULL") |> DataFrame
    networks = Dict("$(row[:name])_$(row[:scenario])" => load_network(row[:network_path]) for row in eachrow(instances))
    for (name, network) in networks
        normalize_index!(network)
    end
    graphs = Dict("$(row[:name])_$(row[:scenario])" => load_graph(row[:graph_path]) for row in eachrow(instances))    
    instances_dict = Dict()
    # Saving instances
    for (name, network) in networks
        if !(name in decompositions_names)
            continue
        end
        # nodes
        if !has_gencost_index(network)
            set_gencost_index!(network)
        end
        bus_dict = Dict(network.bus[!, :ID] .=> _row_to_dict.(eachrow(network.bus[!, Not(:ID)])))
        gen_dict = Dict(network.gen[!, :ID] .=> _row_to_dict.(eachrow(network.gen[!, Not(:ID)])))
        gencost_dict = Dict(network.gencost[!, :ID] .=> _row_to_dict.(eachrow(network.gencost[!, Not(:ID)])))
        node_dict = merge(merge, bus_dict, gen_dict)
        node_dict = merge(merge, node_dict, gencost_dict)

        # edges
        edges = [[row[:SRC], row[:DST]] for row in eachrow(network.branch)]
        branch_dict = Dict(edges .=> _row_to_dict.(eachrow(network.branch[!, Not([:SRC, :DST])])))
        final_dict = Dict("nodes_features" => node_dict, "edges_features" => branch_dict)
        instances_dict[name] = final_dict
    end

    decompositions_dict = Dict()
    # Saving decompositions
    for row in eachrow(decompositions)
        ismissing(row[:solving_time]) && continue
        name = "$(row[:origin_name])_$(row[:origin_scenario])"
        graph = load_graph(row[:graph_path])
        all_edges = [[e.src, e.dst] for e in Graphs.edges(graph)]
        added_edges = [[e.src, e.dst] for e in Graphs.edges(graph) if !(e in Graphs.edges(graphs[name]))]
        decompositions_dict["$(name)_$(row[:uuid])"] = merge(instances_dict[name], Dict("origin_name" => row[:origin_name],
                                                                                        "origin_scenario" => row[:origin_scenario],
                                                                                        "added_edges" => added_edges,
                                                                                        "solving_time" => row[:solving_time],
                                                                                        "uuid" => row[:uuid],
                                                                                        "all_edges" => all_edges,
                                                                                        "type" => get_dec_type(row)
                                                                                       ))
    end
    for (name, decomposition) in decompositions_dict
        open(joinpath(out, "$name.json"), "w") do io
            JSON.print(io, decomposition)
        end
    end
end
