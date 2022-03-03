@testset "Core" begin
        path = "./test/data/case6ww.m"
        network = PowerFlowNetwork(path, "MATPOWER-M")
        @test nbus(network) == 6
        @test nbranch(network) == 11
        @test ngen(network) == 3

        @test has_continuous_index(network) == true
        network.bus = network.bus[1:end .!= 2, :]
        @test has_continuous_index(network) == false

        @test is_disjoint(network) == false
        network.branch = DataFrame(zeros(0, 21), ["SRC", "DST", "BR_R", "BR_X", "BR_B", "RATE_A", "RATE_B", "RATE_C",
                                                  "TAP", "SHIFT", "BR_STATUS", "ANGMIN", "ANGMAX", "PF", "QF", "PT",
                                                  "QT", "MU_SF", "MU_ST", "MU_ANGMIN", "MU_ANGMAX"])
        @test is_disjoint(network) == true
end
