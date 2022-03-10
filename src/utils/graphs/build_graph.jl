function buildmeta(g::AbstractGraph)
    mg = MetaGraph(g)
    for v in vertices(mg)
        set_indexing_prop!(mg, v, :v, v)
    end
    return mg
end

function build_graph_from_cliquetree(cliques::AbstractVector, cliquetree::AbstractVector)
    mg = MetaGraph(length(cliques))
    set_indexing_prop!(mg, :clique)
    for (i, c) in enumerate(cliques)
        set_indexing_prop!(mg, i, :clique, c)
    end
    for edge in cliquetree
        c1 = cliques[edge[1]]
        c2 = cliques[edge[2]]
        src = mg[src, :clique]
        dst = mg[dst, :clique]
        add_edge!(mg, src, dst)
        set_prop!(mg, src, dst, :weight, length(intersect(c1, c2)))
    end
    return mg
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
