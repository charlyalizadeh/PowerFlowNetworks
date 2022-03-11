@testset "DB operations" begin
    db = SQLite.DB("test/data/TEST_PowerFlowNetworks_SQLite.sqlite")
    save_basic_features_instances!(db)
    save_features_instances!(db)
    serialize_instances!(db, "test/data/networks_serialized")
    generate_decompositions!(db, "test/data/cliques", "test/data/cliquetrees",
                             "cholesky", "test/data/configs/preprocess_default.json")
    generate_decompositions!(db, "test/data/cliques", "test/data/cliquetrees",
                             "minimum_degree", "test/data/configs/preprocess_add_random_50.json")
end
