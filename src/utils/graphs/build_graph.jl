function make_complete!(graph, edges)
    for edge in combinations(edges, 2)
        add_edge!(graph, edge...)
    end
end

function buildmeta(g::AbstractGraph)
    mg = MetaGraph(g)
    for v in vertices(mg)
        set_indexing_prop!(mg, v, :v, v)
    end
    return mg
end

function build_graph_from_cliques(cliques::AbstractVector)
    nb_vertex = maximum([maximum(c) for c in cliques])
    g = SimpleGraph(nb_vertex)
    for clique in cliques
        make_complete!(g, clique)
    end
    return g
end

function build_cliquetree(cliques::Vector{Vector{Int}})
    graph = SimpleGraph(length(cliques))
    dstmx = zeros(Int, length(cliques), length(cliques))
    for i in 1:length(cliques) - 1
        for j in i + 1:length(cliques)
            value = length(intersect(cliques[i], cliques[j]))
            dstmx[i, j] = value
            dstmx[j, i] = value
            if value >= 1
                add_edge!(graph, i, j)
            end
        end
    end
    cliquetree = kruskal_mst(graph, dstmx; minimize=false)
    return cliquetree, dstmx
end

function get_cliquetree_array(cliquetree::Vector{Graphs.SimpleEdge{T}}, dstmx) where T
    cliquetree = [[edge.src, edge.dst]::Vector{Int} for edge in cliquetree]
    nb_lc = sum([dstmx[src, dst] * (2 * dstmx[src, dst] + 1) for (src, dst) in cliquetree])
    return cliquetree, nb_lc
end

function get_cliquetree_array(cliques::Vector{Vector{Int}})
    cliquetree, dstmx = build_cliquetree(cliques)
    return get_cliquetree_array(cliquetree, dstmx)
end
