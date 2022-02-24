@testset "Load instance in DB" begin
    db = SQLite.DB("./test/data/TEST_PowerFlowNetworks_SQLite.sqlite")
    name = "case6ww"
    scenario = 0
    source_path = "./test/data/case6ww.m"
    source_type = "MATPOWER-M"
    date = Dates.now()
    load_instance!(db, name, scenario, source_path, source_type, date)

    query = "SELECT * FROM instances"
    results = DBInterface.execute(db, query) |> DataFrame

    @test results[!, :name] == [name]
    @test results[!, :scenario] == [scenario]
    @test results[!, :source_path] == [source_path]
    @test results[!, :source_type] == [source_type]
    @test results[!, :date] == [string(date)]

    @test_throws SQLiteException load_instance!(db, name, scenario, source_path, source_type, date)
end
