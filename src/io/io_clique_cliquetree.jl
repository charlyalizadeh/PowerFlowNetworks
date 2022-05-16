save_clique(clique::Vector{Vector{Int}}, path::AbstractString) = writedlm(path, clique)

function save_cliquetree(cliquetree::Vector{Vector{Int}}, path::AbstractString)
    if isempty(cliquetree) || cliquetree == [[]]
        cliquetree = [[-1, -1]]
    end
    writedlm(path, cliquetree)
end

function read_cliquetree(path)
    cliquetree = readdlm(path, '\t', Int)
    cliquetree = [cliquetree[i, :] for i in 1:size(cliquetree, 1)]
    if cliquetree == [[-1, -1]]
        cliquetree = []
    end
    return cliquetree
end

function read_clique(path)
    lines = split(read(open(path, "r"), String), '\n')[begin:end-1]
    clique = [parse.(Int, split(line, "\t")) for line in lines]
    return clique
end
