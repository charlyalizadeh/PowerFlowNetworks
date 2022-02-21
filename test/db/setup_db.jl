@testset "Setup Database" begin
    db = setup_db("TEST_PowerFlowNetworks_SQLite.sqlite")
    @test SQLite.tables(db)[:name] == ["instances", "decompositions", "mergers", "combinations", "solve_results"]
end
