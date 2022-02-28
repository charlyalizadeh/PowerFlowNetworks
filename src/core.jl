nbus(network::PowerFlowNetwork) = size(network.bus, 1)

function nbranch(network::PowerFlowNetwork; distinct_pair=false)
    if distinct_pair
        return size(unique(network.branch[:, 1:2], dims=1), 1)
    else
        return size(network.branch, 1)
    end
end

ngen(network::PowerFlowNetwork) = size(network.gen, 1)

is_disjoint(network::PowerFlowNetwork) = nbranch(network) < nbus(network) - 1

has_bus(network::PowerFlowNetwork) = nbus(network) > 0

has_branch(network::PowerFlowNetwork) = nbranch(network) > 0

has_gen(network::PowerFlowNetwork) = ngen(network) > 0

function has_continuous_index(network::PowerFlowNetwork; startone=true)
    idx = network.bus[:, 1]
    idx == idx[1]: idx[end] && (idx[1] == 1 || !startone)
end


function normalize_index!(network::PowerFlowNetwork)
    idx_map = [Pair(i, j) for (i, j) in zip(network.bus[:, 1], 1:nbus(network))]
    network.bus[:, 1] = replace(network.bus[:, 1], idx_map...)
    network.gen[:, 1] = replace(network.gen[:, 1], idx_map...)
    network.branch[:, 1] = replace(network.branch[:, 1], idx_map...)
    network.branch[:, 2] = replace(network.branch[:, 2], idx_map...)
end
