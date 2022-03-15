@testset "Clique cliquetree utilities" begin
    g = cycle_graph(4)
    add_edge!(g, 1, 3)
    clique = maximal_cliques(g)
    @test get_nv(clique) == nv(g)
    @test get_ne(clique) == ne(g)
end

