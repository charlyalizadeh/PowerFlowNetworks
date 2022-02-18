nbus(network::PowerFlowNetwork) = size(network.bus, 1)
nbranch(network::PowerFlowNetwork) = size(network.branch, 1)
ngen(network::PowerFlowNetwork) = size(network.gen, 1)
