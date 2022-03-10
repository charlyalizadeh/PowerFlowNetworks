function merge(cliques::AbstractVector, cliquetree::AbstractVector, nb_lc::Int;
               stopfunc::Function, selectfunc::Function=minimize_molzhan)
    if typeof(treshold) <: Int
        treshold = (;cliques, kwargs...) -> length(cliques) >= treshold
    end
    stop = false
    it = 0
    nb_cliques_old = length(cliques)
    while !stop
        h_index = choose_heuristic(;cliques=cliques,
                                   cliquetree=cliquetree, 
                                   it=it,
                                   nb_cliques_old=nb_cliques_old,
                                   heuristics_args...)
        edge = minimizes[h_index](cliques, cliquetree, heuristics_args...)
        edges = vcat(edges..., get_added_edges(cliques[edge[1]], cliques[edge[2]])...)
        cliques, cliquetree = merge_cliques(cliques, cliquetree, edge)
        stop = treshold(;cliques=cliques,
                        cliquetree=cliquetree, 
                        it=it,
                        nb_cliques_old=nb_cliques_old,
                        heuristics_args...)
    end
    return cliques, cliquetree, edges
end
