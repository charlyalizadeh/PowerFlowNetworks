function merge_cliques(cliques, cliquetree, edge)
    c1 = cliques[edge[1]]
    c2 = cliques[edge[2]]
    new_cliques = filter(c -> !(c in [c1, c2]), deepcopy(cliques))
    push!(new_cliques, union(c1, c2))
    new_cliquetree = filter(e -> e != edge, deepcopy(cliquetree))
    update_cliquetree!(new_cliquetree, length(new_cliques), edge)
    return new_cliques, new_cliquetree
end

function update_cliquetree!(cliquetree, nb_cliques, edge)
    sorted_edge = sort(edge)
    for i in 1:length(cliquetree)
        for j in 1:2
            if cliquetree[i][j] in sorted_edge
                cliquetree[i][j] = nb_cliques
            elseif cliquetree[i][j] >= sorted_edge[2]
                cliquetree[i][j] -= 2
            elseif cliquetree[i][j] >= sorted_edge[1]
                cliquetree[i][j] -= 1
            end
        end
    end
end

function get_added_edges(clique1, clique2)
    edges = Set()
    for v1 in clique1
        for v2 in clique2
            if v1 != v2
                push!(edges, (v1, v2))
            end
        end
    end
    return edges
end

function treshold_percent(cliques, percent=0.10)
    treshold =  floor(Int, length(cliques) * percent)
    return treshold == 0 ? 2 : treshold
end
