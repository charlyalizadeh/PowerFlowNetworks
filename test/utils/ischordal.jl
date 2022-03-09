@testset "ischordal" begin
    g = path_graph(3)
    @test ischordal(g)
    add_edge!(g, 1, 3)
    @test ischordal(g)
    g = path_graph(4)
    add_edge!(g, 1, 4)
    @test !ischordal(g)
    add_edge!(g, 1, 4)
    add_edge!(g, 2, 4)
    @test ischordal(g)
end
