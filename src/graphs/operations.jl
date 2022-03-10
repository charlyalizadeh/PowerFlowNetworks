function _get_nb_edges_to_add(nv::Int, nb_edges_to_add::Union{Int, Float64})
    if nb_edges_to_add < 0 || (nb_edges_to_add > 1 && !isinteger(nb_edges_to_add))
        throw(DomainError("`nb_edges_to_add` must be a positive integer or a float between 0 and 1, got $nb_edges_to_add"))
    end
    isinteger(nb_edges_to_add) && return nb_edges_to_add
    return Int(floor(nb_edges_to_add * nv))
end

function _get_edges_distance(g::AbstractGraph, distance::Int, nb_edges_to_add_stop=Inf)
    distance < 0 && throw(DomainError("`distance` must be a positive integer, got $distance."))
    edge_array = []
    for v in randperm(nv(g))
        append!(edge_array, [(v, n[1]) for n in neighborhood_dists(g, v, distance) if n[2] == distance && v < n[1]])
        if length(edge_array) >= nb_edges_to_add_stop
            return edge_array
        end
    end
    return edge_array
end

function add_edges_distance!(g::AbstractGraph, nb_edges_to_add::Union{Int, Float64}; distance::Int, seed=MersenneTwister(42))
    Random.seed!(seed)
    nb_edges_to_add = _get_nb_edges_to_add(nv(g), nb_edges_to_add)
    edge_array = _get_edges_distance(g, distance, nb_edges_to_add)
    nb_edges_to_add_added = 0
    for e in shuffle(edge_array)
        nb_edges_to_add_added += add_edge!(g, e[1], e[2])
        if nb_edges_to_add_added >= nb_edges_to_add
            return nb_edges_to_add_added
        end
    end
    return nb_edges_to_add_added
end

function _get_edges_random(g::AbstractGraph, nb_edges_to_add::Int)
    edges_array = shuffle(collect(edges(Graphs.complement(g))))
    try
        return edges_array[begin:nb_edges_to_add]
    catch BoundsError
        return edges_array
    end
end

function add_edges_random!(g::AbstractGraph, nb_edges_to_add::Union{Int, Float64}; seed=42)
    Random.seed!(seed)
    nb_edges_to_add = _get_nb_edges_to_add(nv(g), nb_edges_to_add)
    edges_array = _get_edges_random(g, nb_edges_to_add)
    for e in edges_array
        add_edge!(g, e.src, e.dst)
    end
    return length(edges_array)
end

const add_edges_func = Dict(
    "distance" => add_edges_distance!,
    "random" => add_edges_random!
)

function add_edges!(g::AbstractGraph, nb_edges_to_add::Union{Int, Float64}, how::AbstractString; kwargs...)
    add_edges_func[how](g, nb_edges_to_add; kwargs...)
end
