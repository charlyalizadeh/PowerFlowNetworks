include("../src/PowerFlowNetworks.jl")

using .PowerFlowNetworks
using Test
using Graphs: ne, nv, SimpleGraph, has_edge


const testdir = dirname(@__FILE__)

tests = [
   "core",
   "io/read_matpower",
   "graphs/graphs"
]

@testset "PowerFlowNetwork" begin
    for t in tests
        tp = joinpath(testdir, "$(t).jl")
        include(tp)
    end
end
