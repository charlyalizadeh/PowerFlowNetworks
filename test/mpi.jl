@testset "MPI" begin
    db = setup_db("test/data/TEST_PowerFlowNetworks_SQLite.sqlite"; delete_if_exists=true)
    load_instance_in_db!(db, "case6ww", 0, "test/data/case6ww.m", "MATPOWERM", Dates.now())
    load_instance_in_db!(db, "C2FEN02312", 3, "test/data/C2FEN02312_3.raw", "RAWGO", Dates.now())
    load_instance_in_db!(db, "C2S6N02045", 1, "test/data/C2S6N02045_1.raw", "RAWGO", Dates.now())

    execute_process_mpi(db, "save_basic_features_instances", "test/log/")
    execute_process_mpi(db, "save_features_instances", "test/log/")
    execute_process_mpi(db, "serialize_instances", "test/log/"; serialize_path="test/data/networks_serialized", graphs_path="test/data/graphs")
    execute_process_mpi(db, "generate_decompositions", "test/log";
                        cliques_path="test/data/cliques",
                        cliquetrees_path="test/data/cliquetrees",
                        graphs_path="test/data/graphs",
                        extension_alg="minimum_degree",
                        preprocess_path="test/data/configs/preprocess_add_random_50.json")
    execute_process_mpi(db, "merge_decompositions", "test/log";
                        heuristic=["molzahn"],
                        heuristic_switch=[0],
                        treshold_name="clique_nv_up",
                        merge_kwargs=Dict("treshold_percent" => 0.5))
    execute_process_mpi(db, "combine_decompositions", "test/log";
                        how="clique_intersect", extension_alg="cholesky")
end
