@testset "Read RAWGO" begin
        path = "./test/data/C2FEN02312_3.raw"
        network = PowerFlowNetwork(path, "RAWGO")
        @test network.baseMVA == 100
        @test size(network.bus, 1) == 2312
        @test nbus(path, "RAWGO") == nbus(network)
        @test nbranch(path, "RAWGO") == nbranch(network)
        @test nbranch(path, "RAWGO", distinct_pair=true) == nbranch(network; distinct_pair=true)
        @test ngen(path, "RAWGO") >= ngen(network)
end
