function merge_decomposition!(db::SQLite.DB, id::Int, name::AbstractString, scenario::Union{Int, AbstractString},
                              clique_path::AbstractString, cliquetree_path::AbstractString, graph_path::AbstractString,
                              nb_added_edge_dec::Int,
                              heuristic::Vector{String}, heuristic_switch::Vector{Int},
                              treshold_name::AbstractString, merge_kwargs::AbstractDict;
                              rng)
    println("Merging decomposition: $name $scenario $id. ($heuristic, $heuristic_switch)")
    
    # Retrieve the cliques array and the cliquetree
    clique = read_clique(clique_path)
    cliquetree = read_cliquetree(cliquetree_path)
    
    # Merge
    merged_clique, merged_cliquetree = merge_dec(clique, cliquetree, heuristic, heuristic_switch;
                                                 treshold_name=treshold_name, merge_kwargs=merge_kwargs)

    # Extract features
    g = loadgraph(graph_path)
    merged_g = build_graph_from_clique(merged_clique)
    features = get_features_graph(merged_g)
    nb_added_edge = ne(merged_g) - ne(g)
    features["nb_lc"] = get_nb_lc(merged_clique, merged_cliquetree)
    features["nb_added_edge_dec"] = nb_added_edge_dec + nb_added_edge
    merge!(features, get_clique_features(merged_clique))

    # Save cliques, cliquetree and graph
    cliques_path = dirname(clique_path)
    cliquetrees_path = dirname(cliquetree_path)
    graphs_path = dirname(graph_path)
    uuid = uuid1(rng)
    clique_path = joinpath(cliques_path, "$(name)_$(scenario)_$(uuid)_clique.csv")
    cliquetree_path = joinpath(cliquetrees_path, "$(name)_$(scenario)_$(uuid)_cliquetree.csv")
    graph_path_merge = joinpath(graphs_path, "$(name)_$(scenario)_$(uuid)_graph.lgz")
    save_clique(merged_clique, clique_path) 
    save_cliquetree(merged_cliquetree, cliquetree_path)
    savegraph(graph_path_merge, merged_g)

    # Other columns
    date = Dates.now()

    features = Dict(Symbol(k) => v for (k, v) in features)
    insert_decomposition!(db, uuid, name, scenario, "merge", "", date, clique_path, cliquetree_path, graph_path_merge; features...)

    # Insert in merge table
    out_id = DBInterface.execute(db, "SELECT id FROM decompositions WHERE uuid = '$uuid'") |> DataFrame
    out_id = out_id[1, :id]
    heuristics_db = join(heuristic, ":")
    treshold_percent = merge_kwargs["treshold_percent"]
    insert_merge!(db, id, out_id, heuristics_db, treshold_name, treshold_percent, nb_added_edge)
end

function merge_decomposition_dfrow!(db::SQLite.DB, row,
                                    heuristic::Vector{String}, heuristic_switch::Vector{Int},
                                    treshold_name::AbstractString, merge_kwargs::AbstractDict; rng)
    merge_decomposition!(db, row[:id], row[:origin_name], row[:origin_scenario], row[:clique_path], row[:cliquetree_path], row[:graph_path], row[:nb_added_edge_dec], 
                         heuristic, heuristic_switch, treshold_name, merge_kwargs, rng=rng)
end

function merge_decompositions!(db::SQLite.DB, heuristic::Vector{String}, heuristic_switch::Vector{Int},
                               treshold_name::AbstractString, merge_kwargs::AbstractDict;
                               rng=MersenneTwister(42), min_nv=typemin(Int), max_nv=typemax(Int),
                               subset=nothing)
    query = "SELECT id, origin_name, origin_scenario, clique_path, cliquetree_path, graph_path, nb_added_edge_dec FROM decompositions WHERE nb_vertex >= $min_nv AND nb_vertex <= $max_nv"
    if !isnothing(subset)
        query *= " AND id IN ($(join(subset, ',')))"
    end
    results = DBInterface.execute(db, query) |> DataFrame
    merge_function!(row) = merge_decomposition_dfrow!(db, row,
                                                      heuristic, heuristic_switch, treshold_name, merge_kwargs;
                                                      rng=rng)
    merge_function!.(eachrow(results[!, [:id, :origin_name, :origin_scenario, :clique_path, :cliquetree_path, :graph_path, :nb_added_edge_dec]]))
end
