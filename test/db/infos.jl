@testset begin "Infos database"
    db = SQLite.DB("test/data/TEST_PowerFlowNetworks_SQLite.sqlite")
    SQLite.drop!(db, "instances")
    @test !has_opf_tables(db)
    db = setup_db("test/data/TEST_PowerFlowNetworks_SQLite.sqlite")
    @test has_opf_tables(db)
    DBInterface.execute(db, "DELETE FROM instances")
    states = state_columns(db, "instances", ["name", "scenario", "nbus", "nbranch", "nbranch_unique", "ngen"])
    @test collect(values(states)) == zeros(Int, length(states))

    name = "case6ww"
    scenario = 0
    source_path = "./test/data/case6ww.m"
    source_type = "MATPOWER-M"
    date = Dates.now()
    load_instance!(db, name, scenario, source_path, source_type, date)


    states = state_columns(db, "instances", ["name", "scenario", "nbus", "nbranch", "nbranch_unique", "ngen"])
    @test states == Dict("name" => 0,
                         "scenario" => 0,
                         "nbus" => 1,
                         "nbus" => 1,
                         "nbranch" => 1,
                         "nbranch_unique" => 1,
                         "ngen" => 1,
                         "total" => 1)

    save_basic_features_instances!(db)
    states = state_columns(db, "instances", ["name", "scenario", "nbus", "nbranch", "nbranch_unique", "ngen"])
    @test collect(values(states)) == zeros(Int, length(states))

    states = state_columns(db, "instances", ["global_clustering_coefficient"])
    @test states["global_clustering_coefficient"] == 1
    @test states["total"] == 1
end

