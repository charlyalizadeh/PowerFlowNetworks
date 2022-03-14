@testset "Clique cliquetree utilities" begin
    g = cycle_graph(4)
    add_edge!(g, 1, 3)
    cliques = maximal_cliques(g)
    @test get_nv(cliques) == nv(g)
    @test get_ne(cliques) == ne(g)
end

