function to_simple_graph(network::PowerFlowNetwork)
    if !has_continuous_index(network)
        network = deepcopy(network)
        normalize_index!(network)
    end
    g = SimpleGraph(nbus(network))
    for (src, dst) in eachrow(network.branch[!, [:SRC, :DST]])
        add_edge!(g, src, dst)
    end
    return g
end
