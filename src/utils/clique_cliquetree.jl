function get_nv(clique)
    length(unique(vcat(clique...)))
end

function get_ne(clique)
    edges = Set([])
    for clique in clique
        for edge in collect(combinations(clique, 2))
            push!(edges, Set(edge))
        end
    end
    return length(edges)
end

function get_nb_lc(clique, cliquetree)
    dstmx = zeros(Int, length(clique), length(clique))
    for i in 1:length(clique) - 1
        for j in i + 1:length(clique)
            value = length(intersect(clique[i], clique[j]))
            dstmx[i, j] = value
            dstmx[j, i] = value
        end
    end
    nb_lc = sum([dstmx[src, dst] * (2 * dstmx[src, dst] + 1) for (src, dst) in cliquetree])
    return nb_lc
end

save_clique(clique::Vector{Vector{Int}}, path::AbstractString) = writedlm(path, clique)

save_cliquetree(cliquetree::Vector{Vector{Int}}, path::AbstractString) = writedlm(path, cliquetree)

function read_cliquetree(path)
    cliquetree = readdlm(path, '\t', Int)
    cliquetree = [cliquetree[i, :] for i in 1:size(cliquetree, 1)]
    return cliquetree
end

function read_clique(path)
    lines = split(read(open(path, "r"), String), '\n')[begin:end-1]
    clique = [parse.(Int, split(line, "\t")) for line in lines]
    return clique
end
