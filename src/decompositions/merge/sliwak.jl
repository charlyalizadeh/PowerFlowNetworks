function sliwak_heuristic(cliques::AbstractVector, edge; merge_kwargs)
    clique1 = cliques[edge[1]]
    clique2 = cliques[edge[2]]
    size_intersect = length(intersect(clique1, clique2))
    size_clique1 = length(clique1)
    size_clique2 = length(clique2)
    size_fusion_clique = size_clique1 + size_clique2 - size_intersect
    nb_lc_new = merge_kwargs["nb_lc"] - size_intersect * (2 * size_intersect + 1)
    q2 = (merge_kwargs["m"] + nb_lc_new)^3
    cost = merge_kwargs["alpha"] * (- size_clique1^3 - size_clique2^3 + size_fusion_clique^3) 
           + merge_kwargs["beta"] * q2
    return cost
end

function update_sliwak(;cliques, edge, merge_kwargs)
    size_intersect = length(intersect(cliques[edge[1]], cliques[edge[2]]))
    merge_kwargs["nb_lc"] -= size_intersect * (2 * size_intersect + 1)
end
