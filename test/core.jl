@testset "Core" begin
        path = "./test/data/case6ww.m"
        network = PowerFlowNetwork(path; format="MATPOWER-M")
        @test nbus(network) == 6
        @test nbranch(network) == 11
        @test ngen(network) == 3

        @test has_continuous_index(network) == true
        network.bus = network.bus[1:end .!= 2, :]
        @test has_continuous_index(network) == false

        @test is_disjoint(network) == false
        network.branch = zeros(0, 0)
        @test is_disjoint(network) == true
end
