function to_simple_graph(network::PowerFlowNetwork)
    g = SimpleGraph(nbus(network))
    for (src, dst) in eachrow(network.branch[begin:end, 1:2])
        add_edge!(g, src, dst)
    end
    return g
end
