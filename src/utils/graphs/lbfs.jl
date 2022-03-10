"""
    get_prior_neighbors(g, ordering, i, exclude=[])
Return the neighbors of `ordering[i]` in `g` with index inferior to i.
"""
function get_prior_neighbors(g, ordering, i, exclude=[])
    prior_neighbors = []
    for j in 1:i-1
        if  !(j in exclude) && (ordering[j] in neighbors(g, ordering[i]))
            push!(prior_neighbors, ordering[j])
        end
    end
    return prior_neighbors
end

"""
    get_later_neighbors(g, ordering, i, exclude=[])
Return the neighbors of `ordering[i]` in `g` with index superior to i.
"""
function get_later_neighbors(g, ordering, i, exclude=[])
    later_neighbors = []
    for j in i+1:length(ordering)
        if !(j in exclude) && (ordering[j] in neighbors(g, ordering[i]))
            push!(later_neighbors, ordering[j])
        end
    end
    return later_neighbors
end

"""
    get_closest_neighbor(g::AbstractGraph, ordering, i)
Return the index of the closest neighbor of the value in `ordering` corresponding to the index `i`.
The return index is inferior to `j`
"""
function get_closest_neighbor(g, ordering, i)
    for j in i-1:-1:1
        if ordering[j] in neighbors(g, ordering[i])
            return j
        end
    end
    return nothing
end

"""
    refine(S, X)
Refine the set `S` into tow sets using `X`.
"""
function refine(S, X)
    intersection = intersect(S, X)
    difference = setdiff(S, X)
    if isempty(intersection)
        return [difference]
    elseif isempty(difference)
        return [intersection]
    else
        return [intersection, difference]
    end
end


"""
    refineset(S, X)
Refine all the sets inside `S` with the set `X`.
"""
function refineset(S, X)
    new_S = []
    for set in S
        append!(new_S, refine(set, X))
    end
    return new_S
end


"""
    lbfs(g)
Return a lexicogic ordering of `G`.
"""
function lbfs(g)
    S = [[vertices(g)...]]
    visited = []
    ordering = []
    for v in vertices(g)
        current_vertex = S[1][1]
        push!(ordering, current_vertex)
        setdiff!(S[1], current_vertex)
        if isempty(S[1])
            popfirst!(S)
        end
        nghbrs = setdiff(neighbors(g, current_vertex), ordering)
        S = refineset(S, nghbrs)
    end
    return ordering
end
