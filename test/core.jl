@testset "Core" begin
        path = "./test/data/case6ww.m"
        network = read_matpower(path)
        @test nbus(network) == 6
        @test nbranch(network) == 11
        @test ngen(network) == 3
end
