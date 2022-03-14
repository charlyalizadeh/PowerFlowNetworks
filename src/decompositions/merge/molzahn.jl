function molzahn_heuristic(cliques::AbstractVector, edge; merge_kwargs=merge_kwargs)
    size_intersect = length(intersect(cliques[edge[1]], cliques[edge[2]]))
    size_clique1 = length(cliques[edge[1]])
    size_clique2 = length(cliques[edge[2]])
    size_fusion = size_clique1 + size_clique2 - size_intersect
    delta = size_fusion * (2 * size_fusion + 1) -
            size_clique1 * (2 * size_clique1 + 1) -
            size_clique2 * (2 * size_clique2 + 1) -
            size_intersect * (2 * size_intersect + 1)
    return delta
end

function update_molzahn(;kwargs...)
end
