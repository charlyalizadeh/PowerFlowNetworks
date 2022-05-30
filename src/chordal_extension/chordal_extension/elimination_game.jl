function elimination_game!(g::AbstractGraph; order=vertices(g))
    mg = buildmeta(g)
    origin_edges = edges(g)
    old_mv = 0
    for v in order
        mv = vertex_s2m(mg, v)
        sedges = getsaturate(mg, mv)
        add_edges!(mg, sedges)
        sedges::Vector{Vector{Int}} = [edge_m2s(mg, e[1], e[2]) for e in sedges]
        add_edges!(g, sedges)
        rem_vertex!(mg, mv)
        old_mv = mv
    end
    data = Dict("added_edges" => setdiff(edges(g), origin_edges))
    return data
end

function elimination_game(g::AbstractGraph; order=vertices(g), kwargs...)
    cg = deepcopy(g)
    data = EG!(cg, order)
    return cg, data
end
