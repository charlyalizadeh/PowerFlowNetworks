"""
    ischordal(g)
return true if `g` is chordal, false otherwise.
"""
function ischordal(g)
    !is_connected(g) && return false
    ne(g) == nv(g) * (nv(g) - 1) / 2 && return true # if g is complete
    ordering = lbfs(g)
    for i in 3:length(ordering)
        index_neighbor = get_closest_neighbor(g, ordering, i)
        if index_neighbor == -1
            continue
        else
            prior_current = get_prior_neighbors(g, ordering, i, [index_neighbor])
            prior_closest = get_prior_neighbors(g, ordering, index_neighbor)
            if !issubset(prior_current, prior_closest)
                return false
            end
        end
    end
    return true
end
