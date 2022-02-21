function to_simple_graph(network::PowerFlowNetwork)
    if !has_continuous_index(network)
        network = deepcopy(network)
        normalize_index!(network)
    end
    g = SimpleGraph(nbus(network))
    for (src, dst) in eachrow(network.branch[begin:end, 1:2])
        add_edge!(g, src, dst)
    end
    return g
end
