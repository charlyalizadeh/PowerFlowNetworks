function _get_nb_edge_to_add(nv::Int, nb_edge::Union{Int, Float64})
    if nb_edge < 0 || (nb_edge > 1 && !isinteger(nb_edge))
        throw(DomainError("`nb_edge` must be a positive integer or a float between 0 and 1, got $nb_edge"))
    end
    isinteger(nb_edge) && return nb_edge
    return Int(floor(nb_edge * nv))
end

function _get_edges_distance(g::AbstractGraph, distance::Int, nb_edge_stop=Inf)
    distance < 0 && throw(DomainError("`distance` must be a positive integer, got $distance."))
    edge_array = []
    for v in randperm(nv(g))
        append!(edge_array, [(v, n[1]) for n in neighborhood_dists(g, v, distance) if n[2] == distance && v < n[1]])
        if length(edge_array) >= nb_edge_stop
            return edge_array
        end
    end
    return edge_array
end

function add_edges_distance!(g::AbstractGraph, nb_edge::Union{Int, Float64}, distance::Int; seed=MersenneTwister(42))
    Random.seed!(seed)
    nb_edge = _get_nb_edge_to_add(nv(g), nb_edge)
    edge_array = _get_edges_distance(g, distance, nb_edge)
    nb_edge_added = 0
    for e in shuffle(edge_array)
        nb_edge_added += add_edge!(g, e[1], e[2])
        if nb_edge_added >= nb_edge
            return nb_edge_added
        end
    end
    return nb_edge_added
end

function _add_edge_random!(g::AbstractGraph)
    src = rand(1:nv(g))
    dst = rand(filter(x -> x != src, 1:nv(g)))
    while had_edge(g, src, dst)
        dst = rand(filter(x -> x != src, 1:nv(g)))
    end
    add_edge!(g, src, dst)
end

function add_edge_random!(g::AbstractGraph, nb_edge::Union{Int, Float64}; seed=42)
    Random.seed!(seed)
    nb_edge = _get_nb_edge_to_add(nv(g), nb_edge)
    for i in 1:nb_edge
        _add_edge_random!(g)
    end
end
