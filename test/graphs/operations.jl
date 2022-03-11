@testset "Graph operations" begin
    g = SimpleGraph(5)
    @test_throws DomainError add_edges_distance!(g, 1.5; distance=5)
    @test_throws DomainError add_edges_distance!(g, 1; distance=-5)

    nb_edges_to_add = add_edges_distance!(g, 2; distance=2)
    @test ne(g) == nb_edges_to_add

    g = path_graph(5)
    nb_edges_to_add = add_edges_distance!(g, 2; distance=2)
    @test ne(g) - 4 == nb_edges_to_add
    added_edges = setdiff(edges(g), edges(path_graph(5)))
    for e in added_edges
        @test abs(e.src - e.dst) == 2
    end
end
