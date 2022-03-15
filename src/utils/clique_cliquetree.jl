function get_nv(cliques)
    length(unique(vcat(cliques...)))
end

function get_ne(cliques)
    edges = Set([])
    for clique in cliques
        for edge in collect(combinations(clique, 2))
            push!(edges, Set(edge))
        end
    end
    return length(edges)
end

function get_nb_lc(cliques, cliquetree)
    dstmx = zeros(Int, length(cliques), length(cliques))
    for i in 1:length(cliques) - 1
        for j in i + 1:length(cliques)
            value = length(intersect(cliques[i], cliques[j]))
            dstmx[i, j] = value
            dstmx[j, i] = value
        end
    end
    nb_lc = sum([dstmx[src, dst] * (2 * dstmx[src, dst] + 1) for (src, dst) in cliquetree])
    return nb_lc
end

save_cliques(cliques::Vector{Vector{Int}}, path::AbstractString) = writedlm(path, cliques)

save_cliquetree(cliquetree::Vector{Vector{Int}}, path::AbstractString) = writedlm(path, cliquetree)

function read_cliquetree(path)
    cliquetree = readdlm(path, '\t', Int)
    cliquetree = [cliquetree[i, :] for i in 1:size(cliquetree, 1)]
    return cliquetree
end

function read_cliques(path)
    lines = split(read(open(path, "r"), String), '\n')[begin:end-1]
    cliques = [parse.(Int, split(line, "\t")) for line in lines]
    return cliques
end
