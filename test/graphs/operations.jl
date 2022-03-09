@testset "Graph operations" begin
    g = SimpleGraph(5)
    @test_throws DomainError add_edges_distance!(g, 1.5, 5)
    @test_throws DomainError add_edges_distance!(g, 1, -5)

    nb_added_edge = add_edges_distance!(g, 2, 2)
    @test ne(g) == nb_added_edge

    g = path_graph(5)
    nb_added_edge = add_edges_distance!(g, 2, 2)
    @test ne(g) - 4 == nb_added_edge
    added_edges = setdiff(edges(g), edges(path_graph(5)))
    for e in added_edges
        @test abs(e.src - e.dst) == 2
    end
end
