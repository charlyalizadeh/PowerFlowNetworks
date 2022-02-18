module PowerFlowNetworks

struct PowerFlowNetwork
    bus::Matrix{Float64}
    gen::Matrix{Float64}
    branch::Matrix{Float64}
    gencost::Matrix{Float64}
end

include("core.jl")
include("io/read.jl")

PowerFlowNetwork(path::AbstractString; format::AbstractString) = read_network(path; format=format)

export nbus, nbranch, ngen
export PowerFlowNetwork

end
