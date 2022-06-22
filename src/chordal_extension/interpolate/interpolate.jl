function interpolate_vertices(g_array)
    g = intersect(g_array[1], g_array[2])
    if length(g_array) > 2
        for temp_g in g_array[3:end]
            g = intersect(g, temp_g)
        end
    end
    return g
end

function interpolate_cliques(g_array)
    g_interpolate = build_graph_from_clique(clique_interpolate)
    clique = [sort(map(sort, maximal_cliques(g))) for g in g_array]
    c = intersect(clique[1], clique[2])
    if length(clique) > 2
        for temp_c in clique[3:end]
            c = intersect(c, temp_c)
        end
    end
    return build_graph_from_clique(c)
end

const interpolate_functions = Dict(
    "vertices" => interpolate_vertices,
    "clique" => interpolate_cliques,
)

function interpolate_graph(g_array; how="vertices")
    return interpolate_functions[how](g_array)
end
