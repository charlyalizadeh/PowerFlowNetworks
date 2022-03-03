@testset "Read features" begin
    g = path_graph(5)
    features_graph = get_features_graph(g)
    @test features_graph["nb_edge"] == 4
    @test features_graph["nb_vertex"] == 5
    @test features_graph["degree_max"] == 2
    @test features_graph["degree_min"] == 1
    @test features_graph["degree_mean"] == 8 / 5
    @test features_graph["global_clustering_coefficient"] == 0
    @test features_graph["density"] == (2 * 4) / (5  * (5 - 1))
    @test features_graph["radius"] == 2
    @test features_graph["diameter"] == 4


    path = "./test/data/case6ww.m"
    network = PowerFlowNetwork(path; format="MATPOWER-M")
    features_opf = get_features_opf(network)

    @test (features_opf["PD_max"], features_opf["PD_min"]) == (70, 0)
    @test (features_opf["QD_max"], features_opf["QD_min"]) == (70, 0)
    @test (features_opf["GS_max"], features_opf["GS_min"]) == (0, 0)
    @test (features_opf["BS_max"], features_opf["BS_min"]) == (0, 0)
    @test (features_opf["VM_max"], features_opf["VM_min"]) == (1.07, 1)
    @test (features_opf["VA_max"], features_opf["VA_min"]) == (0, 0)
    @test (features_opf["VMAX_max"], features_opf["VMAX_min"]) == (1.07, 1.05)
    @test (features_opf["VMIN_max"], features_opf["VMIN_min"]) == (1.07, 0.95)

    # gen
    @test (features_opf["PG_max"], features_opf["PG_min"]) == (60, 0)
    @test (features_opf["QG_max"], features_opf["QG_min"]) == (0, 0)
    @test (features_opf["QMAX_max"], features_opf["QMAX_min"]) == (100, 100)
    @test (features_opf["QMIN_max"], features_opf["QMIN_min"]) == (-100, -100)
    @test (features_opf["PMAX_max"], features_opf["PMAX_min"]) == (200, 150)
    @test (features_opf["PMIN_max"], features_opf["PMIN_min"]) == (50, 37.5)

    # branch
    @test (features_opf["BR_R_max"], features_opf["BR_R_min"]) == (0.2, 0.02)
    @test (features_opf["BR_X_max"], features_opf["BR_X_min"]) == (0.4, 0.1)
    @test (features_opf["BR_B_max"], features_opf["BR_B_min"]) == (0.08, 0.02)
end
