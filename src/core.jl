nbus(network::PowerFlowNetwork) = nrow(network.bus)

function nbranch(network::PowerFlowNetwork; distinct_pair=false)
    if distinct_pair
        return size(unique(network.branch, [:SRC, :DST]), 1)
    else
        return nrow(network.branch)
    end
end

ngen(network::PowerFlowNetwork) = nrow(network.gen)

is_disjoint(network::PowerFlowNetwork) = nbranch(network) < nbus(network) - 1

has_bus(network::PowerFlowNetwork) = nbus(network) > 0

has_branch(network::PowerFlowNetwork) = nbranch(network) > 0

has_gen(network::PowerFlowNetwork) = ngen(network) > 0

function has_continuous_index(network::PowerFlowNetwork; startone=true)
    idx = network.bus[!, :ID]
    idx == idx[1]: idx[end] && (idx[1] == 1 || !startone)
end

function normalize_index!(network::PowerFlowNetwork)
    idx_map = [Pair(i, j) for (i, j) in zip(network.bus[!, :ID], 1:nbus(network))]
    network.bus[!, :ID] = replace(network.bus[!, :ID], idx_map...)
    network.gen[!, :ID] = replace(network.gen[!, :ID], idx_map...)
    network.branch[!, :SRC] = replace(network.branch[!, :SRC], idx_map...)
    network.branch[!, :DST] = replace(network.branch[!, :DST], idx_map...)
end
