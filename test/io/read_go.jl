@testset "Read MATPOWER" begin
        path = "./test/data/C2S6N00014_1.raw"
        network = PowerFlowNetwork(path; format="RAW-GO")
        @test network.baseMVA == 100
        @test size(network.bus, 1) == 14
        @test size(network.gen, 1) == 6
        @test size(network.branch, 1) == 18
end
