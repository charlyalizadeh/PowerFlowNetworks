@testset "Setup Database" begin
    db = setup_db("./test/data/TEST_PowerFlowNetworks_SQLite.sqlite")
    @test SQLite.tables(db)[:name] == ["instances", "decompositions", "mergers", "combinations", "solve_results"]
end
