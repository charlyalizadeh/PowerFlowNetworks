function getsaturate(g, v)::Vector{Vector{Int}}
    return collect(combinations(neighbors(g, v), 2))
end

function argmindeg(g)
    return argmin(degree(g))
end

function add_edges!(g, edges::Vector{Vector{T}}) where T
    added = Vector{Bool}(undef, 0)
    for e in edges
        push!(added, add_edge!(g, e[1], e[2]))
    end
    return added
end

function vertices_meta(g::MetaGraph)
    return Iterators.Stateful([get_prop(g, v, :v) for v in vertices(g)])
end

function edges_meta(g::MetaGraph)
    return Iterators.Stateful([edges_m2s(e) for e in edges(g)])
end

function vertex_m2s(g::MetaGraph, v)
    return get_prop(g, v, :v)
end

function vertex_s2m(g::MetaGraph, v)
    # Here the index are integers so g[v, :v] wouldn't return the node index
    # There seems to be no function to retrieve the index of an integer indexed prop
    # so I access the field `metaindex` directly
    return g.metaindex[:v][v]
end

function edge_m2s(g::MetaGraph, src, dst)
    return [get_prop(g, src, :v), get_prop(g, dst, :v)]
end

function edge_s2m(g::MetaGraph, src, dst)
    return [(g[src, :v], g[dst, :v])]
end
