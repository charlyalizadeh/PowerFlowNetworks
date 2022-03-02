@testset "Read RAWGO" begin
        path = "./test/data/C2FEN02312_3.raw"
        network = PowerFlowNetwork(path; format="RAWGO")
        @test network.baseMVA == 100
        @test size(network.bus, 1) == 2312
        @test nbus(path; format="RAWGO") == nbus(network)
        @test nbranch(path; format="RAWGO") == nbranch(network)
        @test nbranch(path; format="RAWGO", distinct_pair=true) == nbranch(network; distinct_pair=true)
        @test ngen(path; format="RAWGO") >= ngen(network)
end
