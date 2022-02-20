function _parse_rawgo_mat(block; startat=1, eol='\n', delim=',')
    lines = split(block, eol)[startat: end - 1]
    matrix = nothing
    for (i, l) in enumerate(lines)
        if i == 1
            matrix = permutedims(map(x -> tryparse(Float64, x), split(l, delim)))
        else
            array = map(x -> tryparse(Float64, x), split(l, delim))
            matrix = [matrix; permutedims(array)]
        end
    end
    return matrix
end

function _parse_rawgo_bus(data)
    nbus = size(data["BUS"], 1)
    bus = zeros(nbus, 17)

    bus[:, 1] = data["BUS"][:, 1]
    bus[:, 7] = data["BUS"][:, 5]
    bus[:, 8] = data["BUS"][:, 8]
    bus[:, 9] = data["BUS"][:, 9]
    bus[:, 10] = data["BUS"][:, 3]
    bus[:, 11] = data["BUS"][:, 6]
    bus[:, 12] = data["BUS"][:, 10]
    bus[:, 13] = data["BUS"][:, 11]

    idx = trunc.(Int, data["LOAD"][:, 1])
    bus[idx, 3] = data["LOAD"][:, 6]
    bus[idx, 4] = data["LOAD"][:, 7]

    idx = trunc.(Int, data["FIXED SHUNT"][:, 1])
    bus[idx, 5] = data["FIXED SHUNT"][:, 4]
    bus[idx, 6] = data["FIXED SHUNT"][:, 5]
    return bus
end

function _parse_rawgo_gen(data)
    ngen = size(data["GENERATOR"], 1)
    gen = zeros(ngen, 25)

    gen[:, 1] = data["GENERATOR"][:, 1]
    gen[:, 2] = data["GENERATOR"][:, 3]
    gen[:, 3] = data["GENERATOR"][:, 4]
    gen[:, 4] = data["GENERATOR"][:, 5]
    gen[:, 5] = data["GENERATOR"][:, 6]
    gen[:, 7] = data["GENERATOR"][:, 9]
    gen[:, 8] = data["GENERATOR"][:, 10]
    gen[:, 9] = data["GENERATOR"][:, 12]
    gen[:, 10] = data["GENERATOR"][:, 13]

    return gen
end

function _parse_rawgo_branch(data)
    nbranch = size(data["BRANCH"], 1)
    branch = zeros(nbranch, 21)

    branch[:, 1] = data["BRANCH"][:, 1]
    branch[:, 2] = data["BRANCH"][:, 2]
    branch[:, 3] = data["BRANCH"][:, 4]
    branch[:, 4] = data["BRANCH"][:, 5]
    branch[:, 5] = data["BRANCH"][:, 6]
    branch[:, 6] = data["BRANCH"][:, 7]
    branch[:, 7] = data["BRANCH"][:, 8]
    branch[:, 8] = data["BRANCH"][:, 9]
    branch[:, 11] = data["BRANCH"][:, 14]

    return branch
end

function _parse_rawgo_gencost(data)
    # No information on the generators costs
    return zeros(0, 0)
end

function get_data_rawgo(path::AbstractString)
    file_string = read(open(path, "r"), String)
    lines = split(file_string, '\n')
    baseMVA = parse(Float64, split(lines[1], ',')[2])
    blocks = split(file_string, "0 /")
    blocks_name = Dict(
        1 => "BUS",
        2 => "LOAD",
        3 => "FIXED SHUNT",
        4 => "GENERATOR",
        5 => "BRANCH"
    )
    data = Dict()
    for (i, block) in enumerate(blocks)
        occursin("TRANSFORMER", block) && break
        startat = i == 1 ? 4 : 2
        data[blocks_name[i]] = _parse_rawgo_mat(block; startat=startat)
    end
    bus = _parse_rawgo_bus(data)
    gen = _parse_rawgo_gen(data)
    branch = _parse_rawgo_branch(data)
    gencost = _parse_rawgo_gencost(data)
    return bus, gen, branch, gencost, baseMVA
end
