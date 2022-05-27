nbus(network::PowerFlowNetwork) = nrow(network.bus)

function nbranch(network::PowerFlowNetwork; distinct_pair=false)
    if distinct_pair
        return size(unique(network.branch, [:SRC, :DST]), 1)
    else
        return nrow(network.branch)
    end
end

nbranch_unique(network::PowerFlowNetwork) = nbranch(network; distinct_pair=true)

ngen(network::PowerFlowNetwork) = nrow(network.gen)

is_disjoint(network::PowerFlowNetwork) = nbranch(network) < nbus(network) - 1

has_bus(network::PowerFlowNetwork) = nbus(network) > 0

has_branch(network::PowerFlowNetwork) = nbranch(network) > 0

has_gen(network::PowerFlowNetwork) = ngen(network) > 0

function has_continuous_index(network::PowerFlowNetwork; startone=true)
    idx = network.bus[!, :ID]
    idx == idx[1]: idx[end] && (idx[1] == 1 || !startone)
end

function get_cost_type(network::PowerFlowNetwork)
    if isempty(network.gencost)
        return "empty"
    end
    cost_type = network.gencost[!, :MODEL]
    if all(cost_type .== 1)
        return "piecewise linear"
    elseif all(cost_type .== 2)
        return "polynomial"
    elseif all(cost_type .== 1 .|| a.== 2)
        error("Mixed cost types for $(network.name)")
    else
        error("Cost types of $(network.name) contains values not equal to 1 or 2.")
    end
end

function normalize_index!(network::PowerFlowNetwork)
    idx_map = [Pair(i, j) for (i, j) in zip(network.bus[!, :ID], 1:nbus(network))]
    replace!(network.bus[!, :ID], idx_map...)
    replace!(network.gen[!, :ID], idx_map...)
    replace!(network.branch[!, :SRC], idx_map...)
    replace!(network.branch[!, :DST], idx_map...)
end

function merge_duplicate_branch!(network::PowerFlowNetwork)
    gdf = groupby(network.branch, [:SRC, :DST])
    network.branch = combine(gdf,
                             :BR_R => mean,
                             :BR_X => mean,
                             :BR_B => sum,
                             :RATE_A => mean,
                             :RATE_B => mean,
                             :RATE_C => mean,
                             :ANGMIN => minimum,
                             :ANGMAX => maximum,
                             :PF => sum,
                             :QT => sum,
                             :PT => sum,
                             :MU_SF => mean,
                             :MU_ST => mean,
                             :MU_ANGMIN => minimum,
                             :MU_ANGMAX => maximum; renamecols=false)
end

has_gencost_index(network::PowerFlowNetwork) = :ID in names(network.gencost)

function set_gencost_index!(network::PowerFlowNetwork)
    if size(network.gencost, 1) != size(network.gen, 1)
        @warn "The network $(network.name) doesn't have the same dimension for `gencost` and `gen`. Cannot set the index for `gencost`."
    else
        insertcols!(network.gencost, 1, :ID => network.gen[!, :ID])
    end
end

function _convert_gencost_to_polynomial_dfrow(row, order=2)
    ncost = row[4]
    coefficients = row[5: 4 + 2 * ncost]
    points = [[p, c] for (p, c) in zip(coefficients[1:2:end], coefficients[2:2:end])]
    sort!(points, by=x->x[2])
    power = [p[1] for p in points]
    costs = [p[2] for p in points]
    for i in length(power):-1:2
        if power[i] <= power[i - 1]
            power[i - 1] = power[i] - 1
        end
    end
    polynome = fit(power, costs, order)
    new_coeffs = reverse(coeffs(polynome))
    if length(new_coeffs) < order + 1
        new_coeffs = vcat(new_coeffs, zeros(Float64, (order + 1 - length(new_coeffs))))
    end
    return vcat([2], row[2], row[3], [order + 1], new_coeffs)
end

function convert_gencost_to_polynomial!(network::PowerFlowNetwork, order=2)
    convert_function(row) = _convert_gencost_to_polynomial_dfrow(row, order)
    new_rows = convert_function.(eachrow(network.gencost))
    new_rows = reduce(hcat, new_rows)'
    network.gencost = DataFrame(new_rows, vcat(["MODEL", "STARTUP", "SHUTDOWN", "NCOST"], ["COST$i" for i in 1:order+1]))
    network.gencost[!, :MODEL] = floor.(Int, network.gencost[!, :MODEL])
    network.gencost[!, :NCOST] = floor.(Int, network.gencost[!, :NCOST])
end

function convert_gencost!(network::PowerFlowNetwork, to)
    if to == "polynomial"
        convert_gencost_to_polynomial!(network)
    elseif to == "piecewise linear"
        error("Not implemented")
    end
end

function replace_inf_by!(network::PowerFlowNetwork, by=1000000.0)
    replace!(network.gen[!, :QMIN], -Inf => -by)
    replace!(network.gen[!, :QMAX], Inf => by)
end
