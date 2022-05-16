include("export_network_to_matpowerm.jl")

const export_functions = Dict(
    "MATPOWERM" => export_network_to_matpowerm,
)
const export_extension = Dict(
    "MATPOWERM" => ".m"
)


function export_network(io::IO, network::PowerFlowNetwork, to::AbstractString)
    try
        export_functions[to](io, network)
    catch e
        if isa(e, KeyError)
            error("Exporting to $to not implemented. Try one of the following : $(collect(keys(export_functions)))")
        end
    end
end

function export_network(path::AbstractString, network::PowerFlowNetwork, to::AbstractString)
    io = open(path, "w")
    export_network(io, network, to)
end
