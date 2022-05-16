function serialize_network(path::AbstractString, network::PowerFlowNetwork)
    serialize(path, network)
end

function load_network(path::AbstractString)
    return deserialize(path)
end
