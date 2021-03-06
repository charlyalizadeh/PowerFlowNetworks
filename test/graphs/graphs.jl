@testset "Graphs" begin
    # From MATPOWERM files
    path = "./test/data/case6ww.m"
    network = PowerFlowNetwork(path, "MATPOWERM")
    g = SimpleGraph(network)
    @test nv(g) == nbus(network)
    @test ne(g) == nbranch(network)
    edges = [(1, 2), (1, 4), (1, 5), (2, 3), (2, 4), (2, 5), (2, 6), (3, 5), (3, 6), (4, 5), (5, 6)]
    @test ne(g) == length(edges)
    for (src, dst) in edges
        @test has_edge(g, src, dst)
    end

    # From RAWGO files (with non continuous index)
    path = "./test/data/C2S6N02045/scenario_1/"
    network = PowerFlowNetwork(path, "RAWGO")
    g = SimpleGraph(network)
    @test nv(g) == nbus(network)
    @test ne(g) == nbranch(network; distinct_pair=true)
end
