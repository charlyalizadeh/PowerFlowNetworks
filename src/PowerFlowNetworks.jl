module PowerFlowNetworks

using Graphs: SimpleGraph, add_edge!
using SQLite, DataFrames
using Dates

mutable struct PowerFlowNetwork
    bus::Matrix{Float64}
    gen::Matrix{Float64}
    branch::Matrix{Float64}
    baseMVA::Float64
end


include("core.jl")
include("io/read.jl")
include("graphs/graphs.jl")
include("db/setup_db.jl")
include("db/inserts.jl")


PowerFlowNetwork(path::AbstractString; format::AbstractString) = read_network(path; format=format)
SimpleGraph(network::PowerFlowNetwork) = to_simple_graph(network)

export nbus, nbranch, ngen, is_disjoint, has_bus, has_branch, has_gen,
       has_continuous_index, normalize_index
export PowerFlowNetwork
export Graph
export setup_db
export load_instance!

end
