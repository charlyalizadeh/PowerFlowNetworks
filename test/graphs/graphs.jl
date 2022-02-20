@testset "Graphs" begin
    # From MATPOWER-M files
    path = "./test/data/case6ww.m"
    network = PowerFlowNetwork(path; format="MATPOWER-M")
    g = SimpleGraph(network)
    @test nv(g) == nbus(network)
    @test ne(g) == nbranch(network)
    edges = [(1, 2), (1, 4), (1, 5), (2, 3), (2, 4), (2, 5), (2, 6), (3, 5), (3, 6), (4, 5), (5, 6)]
    @test ne(g) == length(edges)
    for (src, dst) in edges
        @test has_edge(g, src, dst)
    end

    # From RAW0-GO files
    path = "./test/data/C2S6N00014_1.raw"
    network = PowerFlowNetwork(path; format="RAW-GO")
    g = SimpleGraph(network)
    @test nv(g) == nbus(network)
    @test ne(g) == nbranch(network)
    edges = [(1, 2), (1, 5), (2, 3), (2, 4), (2, 5), (3, 4), (4, 5), (6, 11), (6, 12), (6, 13), (7, 8), (7, 9), (9, 10),
             (9, 14), (10, 11), (10, 14), (12, 13), (13, 14)]
    @test ne(g) == length(edges)
    for (src, dst) in edges
        @test has_edge(g, src, dst)
    end
end
