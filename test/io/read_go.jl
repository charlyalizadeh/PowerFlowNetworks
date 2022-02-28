@testset "Read RAW-GO" begin
        path = "./test/data/C2FEN02312_3.raw"
        network = PowerFlowNetwork(path; format="RAW-GO")
        @test network.baseMVA == 100
        @test size(network.bus, 1) == 2312
end
