@testset "Core" begin
        path = "./test/data/case6ww.m"
        network = PowerFlowNetwork(path; format="MATPOWER-M")
        @test nbus(network) == 6
        @test nbranch(network) == 11
        @test ngen(network) == 3
end
