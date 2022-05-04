@testset "DB operations" begin
    db = setup_db("test/data/TEST_PowerFlowNetworks_SQLite.sqlite"; delete_if_exists=true)
    load_instance_in_db!(db, "case6ww", 0, "test/data/case6ww.m", "MATPOWERM", Dates.now())
    load_instance_in_db!(db, "C2FEN02312", 3, "test/data/C2FEN02312/scenario_3/case.raw", "RAWGO", Dates.now())
    load_instance_in_db!(db, "C2S6N02045", 1, "test/data/C2S6N02045/scenario_1/", "RAWGO", Dates.now())
    @test table_count(db, "instances") == 3

    save_basic_features_instances!(db)
    save_features_instances!(db)
    serialize_instances!(db;
                         serialize_path="test/data/networks_serialized",
                         graphs_path="test/data/graphs")
    generate_decompositions!(db;
                             cliques_path="test/data/cliques",
                             cliquetrees_path="test/data/cliquetrees",
                             graphs_path="test/data/graphs",
                             extension_alg="cholesky",
                             preprocess_path="test/data/configs/preprocess_default.json",
                             subset=[1, 2])
    @test table_count(db, "decompositions") == 2
    generate_decompositions!(db;
                             cliques_path="test/data/cliques",
                             cliquetrees_path="test/data/cliquetrees",
                             graphs_path="test/data/graphs",
                             extension_alg="minimum_degree",
                             preprocess_path="test/data/configs/preprocess_add_random_50.json",
                             subset=[3])
    @test table_count(db, "decompositions") == 3
    merge_decompositions!(db;
                          heuristic=["molzahn"],
                          heuristic_switch=[0],
                          treshold_name="clique_nv_up",
                          merge_kwargs=Dict("treshold_percent" => 0.5),
                          subset=[1, 2])
    @test table_count(db, "decompositions") == 5
    @test table_count(db, "merges") == 2
    generate_decompositions!(db;
                             cliques_path="test/data/cliques",
                             cliquetrees_path="test/data/cliquetrees",
                             graphs_path="test/data/graphs",
                             extension_alg="minimum_degree",
                             preprocess_path="test/data/configs/preprocess_add_random_50.json",
                             subset=[1])
    combine_decompositions!(db; how="vertices_intersect", extension_alg="cholesky", subset=[1])
    combine_decompositions!(db; how="vertices_union", extension_alg="minimum_degree", subset=[1])
    combine_decompositions!(db; how="clique_intersect", extension_alg="cholesky", subset=[1])
    combine_decompositions!(db; how="clique_union", extension_alg="minimum_degree", subset=[1])
end
