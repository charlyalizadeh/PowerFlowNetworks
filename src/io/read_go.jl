# Hard coded data about RAWGO format
_get_rawgo_colnames() = Dict(
    "BUS" => ["I", "NAME", "BASEKV", "IDE", "AREA", "ZONE", "OWNER", "VM", "VA", "NVHI", "NVLO", "EVHI", "EVLO"],
    "LOAD" => ["I", "ID", "STATUS", "AREA", "ZONE", "PL", "QL", "IP", "IQ", "YP", "YQ", "OWNER", "SCALE", "INTRPT"],
    "FIXED SHUNT" => ["I", "ID", "STATUS", "GL", "BL"],
    "GENERATOR" => ["I", "ID", "PG", "QG", "QT", "QB", "VS", "IREG", "MBASE", "ZR", "ZX", "RT", "XT", "GTAP",
                   "STAT", "RMPCT", "PT", "PB", "O1", "F1", "O2", "F2", "O3", "F3", "O4", "F4", "WMOD", "WPF"],
    "BRANCH" => ["I", "J", "CKT", "R", "X", "B", "RATEA", "RATEB", "RATEC", "GI", "BI", "GJ", "BJ", "ST", "MET",
                "LEN", "O1", "F1", "O2", "F2", "O3", "F3", "O4", "F4"]
)

_get_rawgo_apply_colnames() = Dict(
    "LOAD" => ["PL", "QL"],
    "GENERATOR" => ["PG", "QG", "QT", "QB", "PT", "PB"],
)

# Parse .raw file
function _parse_rawgo_mat(block; startat=1, eol='\n', delim=',')
    lines = split(block, eol)[startat: end - 1]
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
end

# Extract the PowerFlowNetwork fields
function _extract_bus(dfs)
    nbus = size(dfs["BUS"], 1)
    bus = zeros(nbus, 17)

    bus[:, 1] = dfs["BUS"][!, :I]
    bus[:, 7] = dfs["BUS"][!, :AREA]
    bus[:, 8] = dfs["BUS"][!, :VM]
    bus[:, 9] = dfs["BUS"][!, :VA]
    bus[:, 10] = dfs["BUS"][!, :BASEKV]
    bus[:, 11] = dfs["BUS"][!, :ZONE]
    bus[:, 12] = dfs["BUS"][!, :NVHI]
    bus[:, 13] = dfs["BUS"][!, :NVLO]

    if nrow(dfs["LOAD"]) != 0
        idx = findall(in(dfs["LOAD"][!, :I]), bus[:, 1])
        bus[idx, 3] = dfs["LOAD"][:, :PL]
        bus[idx, 4] = dfs["LOAD"][:, :QL]
    end

    if nrow(dfs["FIXED SHUNT"]) != 0
        idx = findall(in(dfs["FIXED SHUNT"][:, :I]), bus[:, 1])
        bus[idx, 5] = dfs["FIXED SHUNT"][:, :GL]
        bus[idx, 6] = dfs["FIXED SHUNT"][:, :BL]
    end

    return bus
end
function _extract_gen(dfs)
    ngen =  nrow(dfs["GENERATOR"])
    if ngen == 0
        return zeros(0, 25)
    end

    gen = zeros(ngen, 25)

    gen[:, 1] = dfs["GENERATOR"][!, :I]
    gen[:, 2] = dfs["GENERATOR"][!, :PG]
    gen[:, 3] = dfs["GENERATOR"][!, :QG]
    gen[:, 4] = dfs["GENERATOR"][!, :QT]
    gen[:, 5] = dfs["GENERATOR"][!, :QB]
    #gen[:, 7] = dfs["GENERATOR"][!, :MBASE]
    #gen[:, 8] = dfs["GENERATOR"][!, :STAT]
    gen[:, 9] = dfs["GENERATOR"][!, :PT]
    gen[:, 10] = dfs["GENERATOR"][!, :PB]

    return gen
end
function _extract_branch(dfs)
    nbranch = nrow(dfs["BRANCH"])
    if nbranch == 0
        return zeros(0, 21)
    end

    branch = zeros(nbranch, 21)

    branch[:, 1] = dfs["BRANCH"][!, :I]
    branch[:, 2] = dfs["BRANCH"][!, :J]
    branch[:, 3] = dfs["BRANCH"][!, :R]
    branch[:, 4] = dfs["BRANCH"][!, :X]
    branch[:, 5] = dfs["BRANCH"][!, :B]
    branch[:, 6] = dfs["BRANCH"][!, :RATEA]
    branch[:, 7] = dfs["BRANCH"][!, :RATEB]
    branch[:, 8] = dfs["BRANCH"][!, :RATEC]
    branch[:, 11] = dfs["BRANCH"][!, :ST]

    return branch
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
    dfs = _data_rawgo_to_dfs(data)
    _clean_rawgo_dfs(dfs)
    return _extract_bus(dfs), _extract_gen(dfs), _extract_branch(dfs), baseMVA
end
