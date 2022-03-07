module PowerFlowNetworks

using Graphs
using SQLite, DataFrames
using Dates
using Statistics: mean
using Serialization

mutable struct PowerFlowNetwork
    bus::DataFrame
    gen::DataFrame
    branch::DataFrame
    baseMVA::Float64
end


include("core.jl")
include("io/read.jl")
include("read_features.jl")
include("graphs/graphs.jl")
include("db/setup_db.jl")
include("db/inserts.jl")
include("db/operations.jl")


PowerFlowNetwork(path::AbstractString, format::AbstractString) = read_network(path, format)
SimpleGraph(network::PowerFlowNetwork) = to_simple_graph(network)

export nbus, nbranch, ngen, is_disjoint, has_bus, has_branch, has_gen,
       has_continuous_index, normalize_index
export nbranch_unique, ngen_unique
export save_features_instances!, save_basic_features_instances!, save_single_features_instances!, serialize_instances!
export PowerFlowNetwork
export Graph
export setup_db
export load_instance!

end
