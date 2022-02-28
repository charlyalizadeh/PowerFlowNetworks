include("../src/PowerFlowNetworks.jl")

using .PowerFlowNetworks
using Test
using Graphs: ne, nv, SimpleGraph, has_edge
using SQLite, DataFrames
using Dates


const testdir = dirname(@__FILE__)

tests = [
   "core",
   "io/read_matpower",
   "io/read_go",
   "graphs/graphs",
   "db/setup_db",
   "db/inserts"
]


try
    @testset "PowerFlowNetwork" begin
        for t in tests
            tp = joinpath(testdir, "$(t).jl")
            include(tp)
        end
    end
finally
    if any(x -> occursin("db", x), tests)
        rm("test/data/TEST_PowerFlowNetworks_SQLite.sqlite")
    end
end
