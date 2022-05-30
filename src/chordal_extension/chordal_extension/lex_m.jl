function lex_m!(g::AbstractGraph)
    origin_edges = edges(g)
    labels = zeros(Int, nv(g))
    order = zeros(Int, nv(g))
    unumbered = collect(vertices(g))
    for i in nv(g):-1:1
        old_labels = copy(labels)
        v = argmax(labels)
        order[i] = v
        filter!(x->x != v, unumbered)
        labels[v] = -1
        for u in unumbered
            lower_labels = filter(x -> old_labels[x] < old_labels[u], unumbered)
            sg, vmap = induced_subgraph(g, vcat([v, u], lower_labels))
            if has_path(sg, findall(==(v), vmap)[1], findall(==(u), vmap)[1])
                labels[u] += i
                add_edge!(g, v, u)
            end
        end
    end
    data = Dict("order" => order,
                "added_edges" => setdiff(edges(g), origin_edges))
    return data
end

function lex_m(g::AbstractGraph; kwargs...)
    cg = SimpleGraph(g)
    data = LEX_M!(cg)
    return cg, data
end
