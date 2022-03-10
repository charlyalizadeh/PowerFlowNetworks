function _get_nb_added_edge(nv::Int, nb_added_edge::Union{Int, Float64})
    if nb_added_edge < 0 || (nb_added_edge > 1 && !isinteger(nb_added_edge))
        throw(DomainError("`nb_added_edge` must be a positive integer or a float between 0 and 1, got $nb_added_edge"))
    end
    isinteger(nb_added_edge) && return nb_added_edge
    return Int(floor(nb_added_edge * nv))
end

function _get_edges_distance(g::AbstractGraph, distance::Int, nb_added_edge_stop=Inf)
    distance < 0 && throw(DomainError("`distance` must be a positive integer, got $distance."))
    edge_array = []
    for v in randperm(nv(g))
        append!(edge_array, [(v, n[1]) for n in neighborhood_dists(g, v, distance) if n[2] == distance && v < n[1]])
        if length(edge_array) >= nb_added_edge_stop
            return edge_array
        end
    end
    return edge_array
end

function add_edges_distance!(g::AbstractGraph, nb_added_edge::Union{Int, Float64}; distance::Int, seed=MersenneTwister(42))
    Random.seed!(seed)
    nb_added_edge = _get_nb_added_edge(nv(g), nb_added_edge)
    edge_array = _get_edges_distance(g, distance, nb_added_edge)
    nb_added_edge_added = 0
    for e in shuffle(edge_array)
        nb_added_edge_added += add_edge!(g, e[1], e[2])
        if nb_added_edge_added >= nb_added_edge
            return nb_added_edge_added
        end
    end
    return nb_added_edge_added
end

function _get_edges_random(g::AbstractGraph, nb_added_edge::Int)
    edges_array = shuffle(collect(edges(Graphs.complement(g))))
    try
        return edges_array[begin:nb_added_edge]
    catch BoundsError
        return edges_array
    end
end

function add_edges_random!(g::AbstractGraph, nb_added_edge::Union{Int, Float64}; seed=42)
    Random.seed!(seed)
    nb_added_edge = _get_nb_added_edge(nv(g), nb_added_edge)
    edges_array = _get_edges_random(g, nb_added_edge)
    for e in edges_array
        add_edge!(g, e.src, e.dst)
    end
    return length(edges_array)
end

const add_edges_func = Dict(
    "distance" => add_edges_distance!,
    "random" => add_edges_random!
)

function add_edges!(g::AbstractGraph, nb_added_edge::Union{Int, Float64}, how::AbstractString; kwargs...)
    add_edges_func[how](g, nb_added_edge; kwargs...)
end
