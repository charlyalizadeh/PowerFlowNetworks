include("../src/PowerFlowNetworks.jl")

using .PowerFlowNetworks
using Test

const testdir = dirname(@__FILE__)

tests = [
   "io/read_matpower",
   "core"
]

@testset "PowerFlowNetwork" begin
    for t in tests
        tp = joinpath(testdir, "$(t).jl")
        include(tp)
    end
end
