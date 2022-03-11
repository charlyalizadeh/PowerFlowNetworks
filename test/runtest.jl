include("../src/PowerFlowNetworks.jl")

using .PowerFlowNetworks
using .PowerFlowNetworks: get_features_graph, get_features_opf, _get_edges_distance
using Test
using Graphs
using SQLite, DataFrames
using Dates


const testdir = dirname(@__FILE__)

tests = [
   "core",
   "read_features",
   "io/read_matpower",
   "io/read_go",
   "graphs/graphs",
   "graphs/operations",
   "db/setup_db",
   "db/inserts",
   "db/operations",
   "db/infos",
   "utils/ischordal"
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
