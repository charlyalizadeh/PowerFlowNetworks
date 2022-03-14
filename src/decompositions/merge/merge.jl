include("molzahn.jl")
include("sliwak.jl")
include("treshold_functions.jl")

const heuristic_func = Dict(
    "molzahn" => molzahn_heuristic,
    "sliwak" => sliwak_heuristic
)

const update_func = Dict(
    "molzahn" => update_molzahn,
    "sliwak" => update_sliwak
)


function update_cliquetree!(cliquetree, nb_cliques, edge)
    sorted_edge = sort(edge)
    for i in 1:length(cliquetree)
        for j in 1:2
            if cliquetree[i][j] in sorted_edge
                cliquetree[i][j] = nb_cliques
            elseif cliquetree[i][j] >= sorted_edge[2]
                cliquetree[i][j] -= 2
            elseif cliquetree[i][j] >= sorted_edge[1]
                cliquetree[i][j] -= 1
            end
        end
    end
end

function merge_cliques(cliques, cliquetree, edge)
    c1 = cliques[edge[1]]
    c2 = cliques[edge[2]]
    new_cliques = filter(c -> !(c in [c1, c2]), deepcopy(cliques))
    push!(new_cliques, union(c1, c2))
    new_cliquetree = filter(e -> e != edge, deepcopy(cliquetree))
    update_cliquetree!(new_cliquetree, length(new_cliques), edge)
    return new_cliques, new_cliquetree
end

function minimize(cliques, cliquetree; heuristic_name, merge_kwargs)
    heuristic = heuristic_func[heuristic_name]
    deltas = [heuristic(cliques, edge; merge_kwargs=merge_kwargs) for edge in cliquetree]
    index = argmin(deltas)
    return cliquetree[index]
end

function merge_dec(cliques::AbstractVector, cliquetree::AbstractVector,
                   heuristics=["sliwak", "molzahn"], heuristic_switch=[1];
                   treshold_name::AbstractString="cliques_nv_up",
                   merge_kwargs::AbstractDict{String, <:Any})
    merge_kwargs = Dict{String, Any}(merge_kwargs)
    merge_kwargs["cliques"] = cliques
    merge_kwargs["cliquetree"] = cliquetree
    treshold = treshold_functions[treshold_name](merge_kwargs)
    iter = 1
    heuristic_index = 1
    heuristic_switch_index = 1
    while treshold(merge_kwargs)
        if iter > heuristic_switch[heuristic_switch_index]
            heuristic_switch_index = heuristic_switch_index == length(heuristic_switch) ? 1 : heuristic_switch_index + 1
            heuristic_index = heuristic_index == length(heuristics) ? 1 : heuristic_index + 1
        end
        heuristic_name = heuristics[heuristic_index]
        edge = minimize(merge_kwargs["cliques"], merge_kwargs["cliquetree"]; heuristic_name=heuristic_name, merge_kwargs=merge_kwargs)
        update_func[heuristic_name](cliques=merge_kwargs["cliques"], cliquetree=merge_kwargs["cliquetree"], edge=edge, merge_kwargs=merge_kwargs)
        merge_kwargs["cliques"], merge_kwargs["cliquetree"] = merge_cliques(merge_kwargs["cliques"], merge_kwargs["cliquetree"], edge)
        iter += 1
    end
    cliques, cliquetree = merge_kwargs["cliques"], merge_kwargs["cliquetree"]
    return cliques, map(c -> map(Int, c), cliquetree)
end
