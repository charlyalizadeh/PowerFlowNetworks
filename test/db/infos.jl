@testset begin "Infos database"
    db = SQLite.DB("test/data/TEST_PowerFlowNetworks_SQLite.sqlite")
    SQLite.drop!(db, "instances")
    @test !has_opf_tables(db)
    db = setup_db("test/data/TEST_PowerFlowNetworks_SQLite.sqlite"; delete_if_exists=true)
    @test table_count(db, "instances") == 0
    @test table_count(db, "decompositions") == 0
    @test table_count(db, "merges") == 0
    @test table_count(db, "combinations") == 0
    @test has_opf_tables(db)
    DBInterface.execute(db, "DELETE FROM instances")
    states = count_missing_columns(db, "instances", ["name", "scenario", "nbus", "nbranch", "nbranch_unique", "ngen"])
    @test collect(values(states)) == zeros(Int, length(states))

    name = "case6ww"
    scenario = 0
    source_path = "./test/data/case6ww.m"
    source_type = "MATPOWER-M"
    date = Dates.now()
    load_instance!(db, name, scenario, source_path, source_type, date)
    @test table_count(db, "instances") == 1
    @test table_count(db, "decompositions") == 0
    @test table_count(db, "merges") == 0
    @test table_count(db, "combinations") == 0


    states = count_missing_columns(db, "instances", ["name", "scenario", "nbus", "nbranch", "nbranch_unique", "ngen"])
    @test states == Dict("name" => 0,
                         "scenario" => 0,
                         "nbus" => 1,
                         "nbus" => 1,
                         "nbranch" => 1,
                         "nbranch_unique" => 1,
                         "ngen" => 1,
                         "total" => 1)

    save_basic_features_instances!(db)
    states = count_missing_columns(db, "instances", ["name", "scenario", "nbus", "nbranch", "nbranch_unique", "ngen"])
    @test collect(values(states)) == zeros(Int, length(states))

    states = count_missing_columns(db, "instances", ["global_clustering_coefficient"])
    @test states["global_clustering_coefficient"] == 1
    @test states["total"] == 1
end

