include("read_matpower.jl")
include("read_psse.jl")
include("read_go.jl")

const read_functions = Dict(
    "MATPOWER-M" => get_data_matpower_m,
    "MATPOWER-MAT" => get_data_matpower_mat,
    "RAW" => get_data_raw,
    "RAWX" => get_data_rawx,
    "RAW-GO" => get_data_rawgo,
)

function read_network(path::AbstractString; format::AbstractString)
    bus, gen, branch, baseMVA = read_functions[format](path)
    colnames = get_matpower_cols()
    bus = DataFrame(bus, colnames["bus"])
    gen = DataFrame(gen, colnames["gen"])
    branch = DataFrame(branch, colnames["branch"])
    return PowerFlowNetwork(bus, gen, branch, baseMVA)
end
