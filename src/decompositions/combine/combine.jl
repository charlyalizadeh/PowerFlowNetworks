function combine_vertices(g1::AbstractGraph, g2::AbstractGraph; extension_alg="cholesky", combine_function=intersect, kwargs...)
    g3 = combine_function(g1, g2)
    if ischordal(g3)
        return g3
    else
        chordal_g, data = chordal_extension(g3, extension_alg)
        return chordal_g
    end
end

function combine_cliques(g1, g2; extension_alg="cholesky", combine_function=intersect, kwargs...)
    cliques1 = sort(map(sort, maximal_cliques(g1)))
    cliques2 = sort(map(sort, maximal_cliques(g2)))
    cliques3 = combine_function(cliques1, cliques2)
    g3 = build_graph_from_cliques(cliques2)
    if ischordal(g3)
        return g3
    else
        chordal_g, data = chordal_extension(g3, extension_alg)
        return chordal_g
    end
end

const combine_functions = Dict(
    "vertices_intersect" => (g1, g2; extension_alg="cholesky") -> combine_vertices(g1, g2; extension_alg=extension_alg, combine_function=intersect),
    "vertices_union" => (g1, g2; extension_alg="cholesky") -> combine_vertices(g1, g2; extension_alg=extension_alg, combine_function=union),
    "cliques_intersect" => (g1, g2; extension_alg="cholesky") -> combine_cliques(g1, g2; extension_alg=extension_alg, combine_function=intersect),
    "cliques_union" => (g1, g2; extension_alg="cholesky") -> combine_cliques(g1, g2; extension_alg=extension_alg, combine_function=union)
)

function combine_graph(g1, g2; how="vertices_intersect", extension_alg="cholesky")
    return combine_functions[how](g1, g2; extension_alg=extension_alg)
end
