module PowerFlowNetworks

using Graphs: SimpleGraph, add_edge!

struct PowerFlowNetwork
    bus::Matrix{Float64}
    gen::Matrix{Float64}
    branch::Matrix{Float64}
    gencost::Matrix{Float64}
    baseMVA::Float64
end

include("core.jl")
include("io/read.jl")
include("graphs/graphs.jl")


PowerFlowNetwork(path::AbstractString; format::AbstractString) = read_network(path; format=format)
SimpleGraph(network::PowerFlowNetwork) = to_simple_graph(network)

export nbus, nbranch, ngen
export PowerFlowNetwork
export Graph

end
