@testset "DB operations" begin
    db = SQLite.DB("./test/data/TEST_PowerFlowNetworks_SQLite.sqlite")
    save_features_instances!(db; serialize_network=true, serialize_path="test/data/networks_serialized")
end
