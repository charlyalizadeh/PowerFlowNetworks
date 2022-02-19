nbus(network::PowerFlowNetwork) = size(network.bus, 1)
nbranch(network::PowerFlowNetwork) = size(network.branch, 1)
ngen(network::PowerFlowNetwork) = size(network.gen, 1)
is_disjoint(network::PowerFlowNetwork) = nbranch(network) < nbus(network) - 1
has_bus(network::PowerFlowNetwork) = nbus(network) > 0
has_branch(network::PowerFlowNetwork) = nbranch(network) > 0
has_gen(network::PowerFlowNetwork) = ngen(network) > 0
