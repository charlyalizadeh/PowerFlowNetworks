module PowerFlowNetworks

struct PowerFlowNetwork
    bus::Matrix{Float64}
    gen::Matrix{Float64}
    branch::Matrix{Float64}
    gencost::Matrix{Float64}
end

include("core.jl")
include("io/read_matpower.jl")

export nbus, nbranch, ngen
export read_matpower

end
