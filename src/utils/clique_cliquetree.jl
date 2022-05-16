function get_nv(clique)
    length(unique(vcat(clique...)))
end

function get_ne(clique)
    edges = Set([])
    for clique in clique
        for edge in collect(combinations(clique, 2))
            push!(edges, Set(edge))
        end
    end
    return length(edges)
end

function get_nb_lc(clique, cliquetree)
    dstmx = zeros(Int, length(clique), length(clique))
    for i in 1:length(clique) - 1
        for j in i + 1:length(clique)
            value = length(intersect(clique[i], clique[j]))
            dstmx[i, j] = value
            dstmx[j, i] = value
        end
    end
    nb_lc = sum([dstmx[src, dst] * (2 * dstmx[src, dst] + 1) for (src, dst) in cliquetree])
    return nb_lc
end

function is_complete(clique)
    nb_vertices = get_nv(clique)
    nb_edges  = get_ne(clique)
    return nb_edges == (nb_vertices * (nb_vertices - 1)) / 2
end
