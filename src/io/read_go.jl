# Hard coded data about RAWGO format
_get_rawgo_colnames() = Dict(
    "BUS" => ["I", "NAME", "BASEKV", "IDE", "AREA", "ZONE", "OWNER", "VM", "VA", "NVHI", "NVLO", "EVHI", "EVLO"],
    "LOAD" => ["I", "ID", "STATUS", "AREA", "ZONE", "PL", "QL", "IP", "IQ", "YP", "YQ", "OWNER", "SCALE", "INTRPT"],
    "FIXED SHUNT" => ["I", "ID", "STATUS", "GL", "BL"],
    "GENERATOR" => ["I", "ID", "PG", "QG", "QT", "QB", "VS", "IREG", "MBASE", "ZR", "ZX", "RT", "XT", "GTAP",
                   "STAT", "RMPCT", "PT", "PB", "O1", "F1", "O2", "F2", "O3", "F3", "O4", "F4", "WMOD", "WPF"],
    "BRANCH" => ["I", "J", "CKT", "R", "X", "B", "RATEA", "RATEB", "RATEC", "GI", "BI", "GJ", "BJ", "ST", "MET",
                "LEN", "O1", "F1", "O2", "F2", "O3", "F3", "O4", "F4"],
    "TRANSFORMER" => ["I", "J", "K", "CKT", "CW", "CZ", "CM", "MAG1", "MAG2", "NMETR", "NAME", "STAT", "O1", "F1",
                      "O2", "F2", "O3", "F3", "O4", "F4", "VECGRP"]
)

_get_rawgo_apply_colnames() = Dict(
    "LOAD" => ["PL", "QL"],
    "GENERATOR" => ["PG", "QG", "QT", "QB", "PT", "PB"],
    "FIXED SHUNT" => ["GL", "BL"]
)


# Parse .raw file
function _parse_rawgo_mat(block; startat=1, eol='\n', delim=',', modulo=1)
    lines = split(block, eol)[startat:end]
    lines = [l for (i, l) in enumerate(lines) if (i - 1) % modulo == 0]
    matrix = zeros(0, 0)
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

# Convert raw matrix to dataframes
function _data_rawgo_to_dfs(data)
    colnames = _get_rawgo_colnames()
    for k in keys(data)
        if size(data[k], 1) == 0
            data[k] = zeros(0, length(colnames[k]))
        end
    end
    return Dict(k => DataFrame(data[k], colnames[k]) for k in keys(data))
end
function _clean_rawgo_df(df; index_cols, apply_cols, func)
    gds = groupby(df, index_cols)
    return combine(gds, apply_cols .=> func; renamecols=false)
end
function _clean_rawgo_dfs(dfs)
    apply_colnames = _get_rawgo_apply_colnames()
    dfs["LOAD"] = _clean_rawgo_df(dfs["LOAD"]; index_cols=["I"], apply_cols=apply_colnames["LOAD"], func=sum)
    dfs["GENERATOR"] = _clean_rawgo_df(dfs["GENERATOR"]; index_cols=["I"], apply_cols=apply_colnames["GENERATOR"], func=sum)
    dfs["FIXED SHUNT"] = _clean_rawgo_df(dfs["FIXED SHUNT"]; index_cols=["I"], apply_cols=apply_colnames["FIXED SHUNT"], func=sum)
end

# Extract the PowerFlowNetwork fields
function _extract_bus(dfs)
    nbus = size(dfs["BUS"], 1)
    bus = zeros(nbus, 17)

    bus[:, [1, 7, 8, 9, 10, 11, 12, 13]] .= dfs["BUS"][!, [:I, :AREA, :VM, :VA, :BASEKV, :ZONE, :NVHI, :NVLO]]

    if nrow(dfs["LOAD"]) != 0
        idx = findall(in(dfs["LOAD"][!, :I]), bus[:, 1])
        bus[idx, [3, 4]] .= dfs["LOAD"][:, [:PL, :QL]]
    end

    if nrow(dfs["FIXED SHUNT"]) != 0
        idx = findall(in(dfs["FIXED SHUNT"][:, :I]), bus[:, 1])
        bus[idx, [5, 6]] .= dfs["FIXED SHUNT"][:, [:GL, :BL]]
    end

    return bus
end
function _extract_gen(dfs)
    ngen =  nrow(dfs["GENERATOR"])
    if ngen == 0
        return zeros(0, 25)
    end
    gen = zeros(ngen, 25)
    gen[:, [1, 2, 3, 4, 5, 9, 10]] .= dfs["GENERATOR"][!, [:I, :PG, :QG, :QT, :QB, :PT, :PB]]
    return gen
end
function _extract_branch(dfs)
    nbranch = nrow(dfs["BRANCH"]) + nrow(dfs["TRANSFORMER"])
    if nbranch == 0
        return zeros(0, 21)
    end
    branch = zeros(nbranch, 21)
    branch[begin:nrow(dfs["BRANCH"]), [1, 2, 3, 4, 5, 6, 7, 8, 11]] .= dfs["BRANCH"][!, [:I, :J, :R, :X, :B, :RATEA, :RATEB, :RATEC, :ST]]
    branch[nrow(dfs["BRANCH"]) + 1:end, [1, 2]] .= dfs["TRANSFORMER"][!, [:I, :J]]
    return branch
end

function get_data_rawgo(path::AbstractString)
    file_string = read(open(path, "r"), String)
    lines = split(file_string, '\n')
    baseMVA = parse(Float64, split(lines[1], ',')[2])
    blocks = split(file_string, r"\n0 \/")
    blocks_name = Dict(
        1 => "BUS",
        2 => "LOAD",
        3 => "FIXED SHUNT",
        4 => "GENERATOR",
        5 => "BRANCH",
        6 => "TRANSFORMER"
    )
    data = Dict()
    stop_pattern = ["END OF TRANSFORMER", "end transformer"]
    for (i, block) in enumerate(blocks)
        any(map(x -> occursin(x, block), stop_pattern)) && break
        startat = i == 1 ? 4 : 2
        modulo = i == 6 ? 4 : 1
        data[blocks_name[i]] = _parse_rawgo_mat(block; startat=startat, modulo=modulo)
    end
    dfs = _data_rawgo_to_dfs(data)
    _clean_rawgo_dfs(dfs)
    return _extract_bus(dfs), _extract_gen(dfs), _extract_branch(dfs), baseMVA
end

# Core
function nbus_rawgo(path::AbstractString)
    file_string = read(open(path, "r"), String)
    blocks = split(file_string, r"\n0 \/")
    nbus = length(split(blocks[1], '\n')) - 3
    return nbus
end

function nbranch_rawgo(path::AbstractString; distinct_pair=false)
    nbranch = nothing
    file_string = read(open(path, "r"), String)
    blocks = split(file_string, r"\n0 \/")
    if distinct_pair
        lines = split(blocks[5], '\n')[2:end]
        branches = [Set(parse.(Int, split(l, ',')[1:2])) for l in lines]
        nbranch = length(unique(branches))
    else
        nbranch = length(split(blocks[5], '\n')) - 1
    end
    return nbranch
end

function ntransformer_rawgo(path::AbstractString; distinct_pair=false)
    ntransformer = nothing
    file_string = read(open(path, "r"), String)
    blocks = split(file_string, r"\n0 \/")
    if distinct_pair
        lines = split(blocks[6], '\n')[2:end]
        lines = [l for (i, l) in enumerate(lines) if (i - 1) % 4 == 0]
        transformers = [Set(parse.(Int, split(l, ',')[1:2])) for l in lines]
        ntransformer = length(unique(transformers))
    else
        lines = split(blocks[6], '\n')[2:end]
        lines = [l for (i, l) in enumerate(lines) if (i - 1) % 4 == 0]
        ntransformer = length(lines)
    end
    return ntransformer
end

function ngen_rawgo(path::AbstractString; distinct_pair=false)
    ngen = nothing
    file_string = read(open(path, "r"), String)
    blocks = split(file_string, r"\n0 \/")
    if distinct_pair
        lines = split(blocks[4], '\n')[2:end]
        branches = [parse(Int, split(l, ',')[1]) for l in lines]
        nbranch = length(unique(branches))
    else
        ngen = length(split(blocks[4], '\n')) - 1
    end
    return ngen
end
