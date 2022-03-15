@testset "DB operations" begin
    db = setup_db("test/data/TEST_PowerFlowNetworks_SQLite.sqlite"; delete_if_exists=true)
    load_instance_in_db!(db, "case6ww", 0, "test/data/case6ww.m", "MATPOWER-M", Dates.now())
    load_instance_in_db!(db, "C2FEN02312", 3, "test/data/C2FEN02312_3.raw", "RAWGO", Dates.now())
    load_instance_in_db!(db, "C2S6N02045", 1, "test/data/C2S6N02045_1.raw", "RAWGO", Dates.now())
    @test table_count(db, "instances") == 3

    save_basic_features_instances!(db)
    save_features_instances!(db)
    serialize_instances!(db, "test/data/networks_serialized", "test/data/graphs")
    generate_decompositions!(db, "test/data/cliques", "test/data/cliquetrees", "test/data/graphs",
                             "cholesky", "test/data/configs/preprocess_default.json";
                             subset=[("C2FEN02312", 3), ("case6ww", 0)])
    @test table_count(db, "decompositions") == 2
    generate_decompositions!(db, "test/data/cliques", "test/data/cliquetrees", "test/data/graphs",
                             "minimum_degree", "test/data/configs/preprocess_add_random_50.json";
                             subset=[("C2S6N02045", 1)])
    @test table_count(db, "decompositions") == 3
    merge_decompositions!(db, ["molzahn"], [0], "clique_nv_up", Dict("treshold_percent" => 0.5); subset=[1, 2])
    @test table_count(db, "decompositions") == 5
    @test table_count(db, "merges") == 2
    generate_decompositions!(db, "test/data/cliques", "test/data/cliquetrees", "test/data/graphs",
                             "minimum_degree", "test/data/configs/preprocess_add_random_50.json", subset=[("case6ww", 0)])
    combine_decompositions!(db; how="vertices_intersect", extension_alg="cholesky", subset=[("case6ww", 0)])
    combine_decompositions!(db; how="vertices_union", extension_alg="minimum_degree", subset=[("case6ww", 0)])
    combine_decompositions!(db; how="clique_intersect", extension_alg="cholesky", subset=[("case6ww", 0)])
    combine_decompositions!(db; how="clique_union", extension_alg="minimum_degree", subset=[("case6ww", 0)])
end
