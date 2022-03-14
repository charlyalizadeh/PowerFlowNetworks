_save_cliques(cliques::Vector{Vector{Int}}, path::AbstractString) = writedlm(path, cliques)
_save_cliquetree(cliquetree::Vector{Vector{Int}}, path::AbstractString) = writedlm(path, cliquetree)
function _read_cliquetree(path)
    cliquetree = readdlm(path, '\t', Int)
    cliquetree = [cliquetree[i, :] for i in 1:size(cliquetree, 1)]
    return cliquetree
end
function _read_cliques(path)
    lines = split(read(open(path, "r"), String), '\n')[begin:end-1]
    cliques = [parse.(Int, split(line, "\t")) for line in lines]
    return cliques
end

function merge_decomposition!(db::SQLite.DB, id::Int, name::AbstractString, scenario::Union{Int, AbstractString},
                              clique_path::AbstractString, cliquetree_path::AbstractString, graph_path::AbstractString,
                              nb_added_edge_dec::Int,
                              heuristic::Vector{String}, heuristic_switch::Vector{Int},
                              treshold_name::AbstractString, merge_kwargs::AbstractDict;
                              rng)
    println("Merging decomposition: $name $scenario $id. ($heuristic, $heuristic_switch)")
    
    # Retrieve the cliques array and the cliquetree
    cliques = _read_cliques(clique_path)
    cliquetree = _read_cliquetree(cliquetree_path)
    
    # Merge
    merged_cliques, merged_cliquetree = merge_dec(cliques, cliquetree, heuristic, heuristic_switch;
                                                  treshold_name=treshold_name, merge_kwargs=merge_kwargs)

    # Extract features
    g = loadgraph(graph_path)
    merged_g = build_graph_from_cliques(merged_cliques)
    features = get_features_graph(merged_g)
    nb_edge_added = ne(merged_g) - ne(g)
    features["nb_added_edge_dec"] = nb_added_edge_dec + nb_edge_added
    merge!(features, get_cliques_features(merged_cliques))
    if nb_edge_added < 0
        println("The merge removed $nb_edge_added edges.")
        println("NE original: $(ne(g))")
        println("NE merged: $(ne(merged_g))")
        println("NE merged from cliques: $(get_ne(merged_cliques))")
        readlines()
    end

    # Save cliques, cliquetree and graph
    cliques_path = dirname(clique_path)
    cliquetrees_path = dirname(cliquetree_path)
    graphs_path = dirname(graph_path)
    uuid = uuid1(rng)
    clique_path = joinpath(cliques_path, "$(name)_$(scenario)_$(uuid)_cliques.csv")
    cliquetree_path = joinpath(cliquetrees_path, "$(name)_$(scenario)_$(uuid)_cliquetree.csv")
    graph_path_merge = joinpath(graphs_path, "$(name)_$(scenario)_$(uuid)_graph.lgz")
    _save_cliques(cliques, clique_path) 
    _save_cliquetree(cliquetree, cliquetree_path)
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
    insert_merge!(db, id, out_id, heuristics_db, treshold_name, treshold_percent, nb_edge_added)
end

function merge_decomposition_dfrow!(db::SQLite.DB, row,
                                    heuristic::Vector{String}, heuristic_switch::Vector{Int},
                                    treshold_name::AbstractString, merge_kwargs::AbstractDict; rng)
    merge_decomposition!(db, row[:id], row[:origin_name], row[:origin_scenario], row[:clique_path], row[:cliquetree_path], row[:graph_path], row[:nb_added_edge_dec], 
                         heuristic, heuristic_switch, treshold_name, merge_kwargs, rng=rng)
end

function merge_decompositions!(db::SQLite.DB, heuristic::Vector{String}, heuristic_switch::Vector{Int},
                               treshold_name::AbstractString, merge_kwargs::AbstractDict;
                               rng=MersenneTwister(42), min_nv=typemin(Int), max_nv=typemax(Int))
    query = "SELECT id, origin_name, origin_scenario, clique_path, cliquetree_path, graph_path, nb_added_edge_dec FROM decompositions WHERE nb_vertex >= $min_nv AND nb_vertex <= $max_nv"
    results = DBInterface.execute(db, query) |> DataFrame
    merge_func!(row) = merge_decomposition_dfrow!(db, row,
                                                  heuristic, heuristic_switch, treshold_name, merge_kwargs;
                                                  rng=rng)
    merge_func!.(eachrow(results[!, [:id, :origin_name, :origin_scenario, :clique_path, :cliquetree_path, :graph_path, :nb_added_edge_dec]]))
end
