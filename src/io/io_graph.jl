function serialize_graph(path::AbstractString, graph::AbstractGraph)
    savegraph(path, graph)
end

function load_graph(path::AbstractString)
    return loadgraph(path)
end
