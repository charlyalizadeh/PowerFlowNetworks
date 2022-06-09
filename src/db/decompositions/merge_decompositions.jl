function merge_decomposition!(db::SQLite.DB, id::Int, origin_id::Int, name::AbstractString, scenario::Union{Int, AbstractString},
                              clique_path::AbstractString, cliquetree_path::AbstractString, graph_path::AbstractString,
                              nb_added_edge_dec::Int,
                              heuristic::Vector{String}, heuristic_switch::Vector{Int},
                              treshold_name::AbstractString, merge_kwargs::AbstractDict;
                              rng)
    println("Merging decomposition: ($name, $scenario) $id")
    
    # Retrieve the cliques array and the cliquetree
    clique = read_clique(clique_path)
    if is_complete(clique)
        @warn "Decomposition ($name, $scenario) $id corresponds to a complete graph. Merge aborted."
        return
    end
    cliquetree = read_cliquetree(cliquetree_path)
    
    # Merge
    merged_clique, merged_cliquetree = merge_dec(clique, cliquetree, heuristic, heuristic_switch;
                                                 treshold_name=treshold_name, merge_kwargs=merge_kwargs)

    # Extract features
    g = load_graph(graph_path)
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
    serialize_graph(graph_path_merge, merged_g)

    # Other columns
    date = Dates.now()

    features = Dict(Symbol(k) => v for (k, v) in features)
    insert_decomposition!(db, origin_id, uuid, name, scenario, "merge", "", "", date, clique_path, cliquetree_path, graph_path_merge; wait_until_executed=true, features...)

    # Insert in merge table
    out_id = execute_query(db, "SELECT id FROM decompositions WHERE uuid = '$uuid'"; return_results=true)
    out_id = out_id[1, :id]
    heuristics_db = join(heuristic, ":")
    treshold_percent = merge_kwargs["treshold_percent"]
    insert_merge!(db, id, out_id, heuristics_db, treshold_name, treshold_percent, nb_added_edge)
end

function merge_decompositions!(db::SQLite.DB;
                               heuristic::Vector{String}, heuristic_switch::Vector{Int},
                               treshold_name::AbstractString, kwargs_path::AbstractString, kwargs_key::AbstractString,
                               min_nv=typemin(Int), max_nv=typemax(Int), subset=nothing,
                               rng=MersenneTwister(42), kwargs...)
    merge_kwargs = TOML.parsefile(kwargs_path)[kwargs_key]
    query = "SELECT id, origin_id, origin_name, origin_scenario, clique_path, cliquetree_path, graph_path, nb_added_edge_dec FROM decompositions WHERE nb_vertex >= $min_nv AND nb_vertex <= $max_nv"
    if !isnothing(subset)
        query *= " AND id IN ($(join(subset, ',')))"
    end
    results = DBInterface.execute(db, query) |> DataFrame
    println("Merging config: heuristic=$heuristic heuristic_switch=$heuristic_switch, treshold_name=$treshold_name, min_nv=$min_nv, max_nv=$max_nv, rng=$rng")
    println("merge_kwargs\n$merge_kwargs\nend merge_kwargs")
    println("subset\n$subset\nend subset")
    merge_function!(row) = merge_decomposition!(db, row[:id], row[:origin_id], row[:origin_name], row[:origin_scenario], row[:clique_path], row[:cliquetree_path], row[:graph_path], row[:nb_added_edge_dec],
                                                heuristic, heuristic_switch, treshold_name, merge_kwargs;
                                                rng=rng)
    merge_function!.(eachrow(results))
end
