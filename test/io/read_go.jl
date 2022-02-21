@testset "Read RAW-GO" begin
        path = "./test/data/C2S6N02045_1.raw"
        network = PowerFlowNetwork(path; format="RAW-GO")
        @test network.baseMVA == 100
        @test size(network.bus, 1) == 2045
end
