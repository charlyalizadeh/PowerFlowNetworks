function mcs_m!(g::AbstractGraph)
    origin_edges = edges(g)
    weights = zeros(Int, nv(g))
    order = zeros(Int, nv(g))
    unumbered = collect(vertices(g))
    for i in nv(g):-1:1
        old_weights = copy(weights)
        z = argmax(weights)
        order[i] = z
        filter!(x->x != z, unumbered)
        weights[z] = -1
        for y in unumbered
            lower_weight = filter(x -> old_weights[x] < old_weights[y], unumbered)
            sg, vmap = induced_subgraph(g, vcat(lower_weight, [z, y]))
            if has_path(sg, findall(==(y), vmap)[1], findall(==(z), vmap)[1])
                weights[y] += 1
                add_edge!(g, y, z)
            end
        end
    end
    data = Dict("order" => order,
                "added_edges" => setdiff(edges(g), origin_edges))
    return data
end

function mcs_m(g::AbstractGraph; kwargs...)
    cg = SimpleGraph(g)
    data = MCS_M!(cg)
    return cg, data
end
