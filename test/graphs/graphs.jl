@testset "Graphs" begin
    path = "./test/data/case6ww.m"
    network = PowerFlowNetwork(path; format="MATPOWER-M")
    g = SimpleGraph(network)
    @test nv(g) == nbus(network)
    @test ne(g) == nbranch(network)
    edges = [(1, 2), (1, 4), (1, 5), (2, 3), (2, 4), (2, 5), (2, 6), (3, 5), (3, 6), (4, 5), (5, 6)]
    for (src, dst) in edges
        @test has_edge(g, src, dst)
    end
end
