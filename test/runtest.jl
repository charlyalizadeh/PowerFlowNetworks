include("../src/PowerFlowNetworks.jl")

using .PowerFlowNetworks
using .PowerFlowNetworks: get_features_graph, get_features_opf, _get_edges_distance, get_nv, get_ne
using Test
using Graphs
using SQLite, DataFrames
using Dates

const db_path = "test/data/TEST_PowerFlowNetworks_SQLite.sqlite"
isfile(db_path) && rm(db_path)
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
   "utils/ischordal",
   "utils/clique_cliquetree"
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
        rm(db_path)
    end
end
