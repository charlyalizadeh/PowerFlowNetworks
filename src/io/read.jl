include("read_matpower.jl")
include("read_psse.jl")
include("read_go.jl")

const get_data_functions = Dict(
    "MATPOWER-M" => get_data_matpower_m,
    "MATPOWER-MAT" => get_data_matpower_mat,
    "RAW" => get_data_raw,
    "RAWX" => get_data_rawx,
    "RAWGO" => get_data_rawgo
)
const nbus_functions = Dict(
    "MATPOWER-M" => nbus_matpower_m,
    "MATPOWER-MAT" => nbus_matpower_mat,
    "RAW" => nbus_raw,
    "RAWX" => nbus_rawx,
    "RAWGO" => nbus_rawgo
)
const nbranch_functions = Dict(
    "MATPOWER-M" => nbranch_matpower_m,
    "MATPOWER-MAT" => nbranch_matpower_mat,
    "RAW" => nbranch_raw,
    "RAWX" => nbranch_rawx,
    "RAWGO" => nbranch_rawgo
)
const ngen_functions = Dict(
    "MATPOWER-M" => ngen_matpower_m,
    "MATPOWER-MAT" => ngen_matpower_mat,
    "RAW" => ngen_raw,
    "RAWX" => ngen_rawx,
    "RAWGO" => ngen_rawgo
)

function read_network(path::AbstractString, format::AbstractString)
    bus, gen, branch, baseMVA = get_data_functions[format](path)
    colnames = get_matpower_cols()
    bus = DataFrame(bus, colnames["bus"])
    gen = DataFrame(gen, colnames["gen"])
    branch = DataFrame(branch, colnames["branch"])
    return PowerFlowNetwork(bus, gen, branch, baseMVA)
end

nbus(path::AbstractString, format::AbstractString) = nbus_functions[format](path)
nbranch(path::AbstractString, format::AbstractString; distinct_pair=false) = nbranch_functions[format](path; distinct_pair)
ngen(path::AbstractString, format::AbstractString; distinct_pair=false) = ngen_functions[format](path; distinct_pair)

function nbus(path::AbstractString)
    extension = splitext(path)[end]
    if extension == ".m"
        nbus(path, "MATPOWER-M")
    elseif extension == ".raw"
        nbus(path, "RAWGO")
    else
        error("Not Implemented")
    end
end
function nbranch(path::AbstractString; distinct_pair=false)
    extension = splitext(path)[end]
    if extension == ".m"
        nbranch(path, "MATPOWER-M"; distinct_pair=distinct_pair)
    elseif extension == ".raw"
        nbranch(path, "RAWGO"; distinct_pair=distinct_pair)
    else
        error("Not Implemented")
    end
end
function ngen(path::AbstractString; distinct_pair=false)
    extension = splittext(path)[end]
    if extension == ".m"
        ngen(path, "MATPOWER-M"; distinct_pair=distinct_pair)
    elseif extension == ".raw"
        ngen(path, "RAWGO"; distinct_pair=distinct_pair)
    else
        error("Not Implemented")
    end
end

nbranch_unique(path::AbstractString) = nbranch(path::AbstractString; distinct_pair=true)
ngen_unique(path::AbstractString) = ngen(path::AbstractString; distinct_pair=true)
