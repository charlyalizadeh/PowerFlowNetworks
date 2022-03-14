function get_nv(cliques)
    length(unique(vcat(cliques...)))
end

function get_ne(cliques)
    edges = Set([])
    for clique in cliques
        for edge in collect(combinations(clique, 2))
            push!(edges, Set(edge))
        end
    end
    return length(edges)
end
