@testset "Read RAWGO" begin
        path = "./test/data/C2FEN02312/scenario_3/"
        raw_path = joinpath(path, "case.raw")
        network = PowerFlowNetwork(path, "RAWGO")
        @test network.baseMVA == 100
        @test size(network.bus, 1) == 2312
        @test nbus(raw_path, "RAWGO") == nbus(network)
        @test nbranch(raw_path, "RAWGO") == nbranch(network)
        @test nbranch(raw_path, "RAWGO", distinct_pair=true) == nbranch(network; distinct_pair=true)
        @test ngen(raw_path, "RAWGO") >= ngen(network)
end
