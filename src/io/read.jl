include("read_matpower.jl")
include("read_psse.jl")
include("read_go.jl")

const read_functions = Dict(
    "MATPOWER-M" => get_matpower_m_data,
    "MATPOWER-MAT" => get_matpower_mat_data,
    "RAW" => get_raw_data,
    "RAWX" => get_rawx_data,
    "RAW-GO" => get_rawgo_data,
)

function read_network(path::AbstractString; format::AbstractString)
    bus, gen, branch, gencost = read_functions[format](path)
    return PowerFlowNetwork(bus, gen, branch, gencost)
end
