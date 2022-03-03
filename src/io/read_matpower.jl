get_matpower_cols() = Dict(
    "bus" => ["ID", "TYPE", "PD", "QD", "GS", "BS", "BUS_AREA", "VM", "VA", "BASE_KV", "ZONE", "VMAX", "VMIN", "LAM_P",
              "LAM_Q", "MU_VMAX", "MU_VMIN"],
    "gen" => ["ID", "PG", "QG", "QMAX", "QMIN", "VG", "MBASE", "GEN_STATUS", "PMAX", "PMIN", "PC1", "PC2", "QC1MIN",
              "QC1MAX", "QC2MIN", "QC2MAX", "RAMP_AGC", "RAMP_10", "RAMP_30", "RAMP_Q", "APF", "MU_PMAX", "MU_PMIN",
              "MU_QMAX", "MU_QMIN"],
    "branch" => ["SRC", "DST", "BR_R", "BR_X", "BR_B", "RATE_A", "RATE_B", "RATE_C", "TAP", "SHIFT", "BR_STATUS",
                 "ANGMIN", "ANGMAX", "PF", "QF", "PT", "QT", "MU_SF", "MU_ST", "MU_ANGMIN", "MU_ANGMAX"],
    "gencost" => ["MODEL", "STARTUP", "SHUTDOWN", "NCOST", "COST"]
)

function _row_to_array_matpower_mat(row)
    row = split(row, ';')[1]
    values = split(row, '\t')[2:end]
    array = map(x -> parse(Float64, x), values) 
    return array
end

function _parse_matrix_matpower_mat(lines, start)
    nb_cols = length(split(lines[start], '\t')) - 1
    current_line = start
    matrix = nothing
    while !occursin("];", lines[current_line])
        if isnothing(matrix)
            matrix = transpose(_row_to_array_matpower_mat(lines[current_line]))
        else
            matrix = [matrix; transpose(_row_to_array_matpower_mat(lines[current_line]))]
        end
        current_line += 1
    end
    return matrix
end

function get_data_matpower_m(path::AbstractString)
    file_string = read(open(path, "r"), String)
    lines = split(file_string, '\n')
    lines = [l for l in lines if !startswith(lstrip(l), "%")]
    data = Dict()
    occursin_pattern = ["mpc.bus", "mpc.gen ", "mpc.branch"]
    occursin_key = ["bus", "gen", "branch"]
    dims = [17, 25, 21]
    pattern_idx = 1
    for (i, f) in enumerate(lines)
        if occursin("mpc.baseMVA", f)
            data["baseMVA"] = parse(Float64, split(f[15:end], ';')[end - 1])
        elseif occursin(occursin_pattern[pattern_idx], f)
            key = occursin_key[pattern_idx]
            mat = _parse_matrix_matpower_mat(lines, i + 1)
            sizes = size(mat)
            data[key] = zeros(sizes[1], dims[pattern_idx])
            data[key][1:sizes[1], 1:sizes[2]] = mat
            pattern_idx += 1
            if pattern_idx > length(occursin_pattern)
                break
            end
        end
    end
    return data["bus"], data["gen"], data["branch"], data["baseMVA"]
end

function get_data_matpower_mat(path::AbstractString)
    error("Not Implemented")
end


nbus_matpower_mat(path::AbstractString) = error("Not Implemented")
nbranch_matpower_mat(path::AbstractString; distinct_pair=false) = error("Not Implemented")
ngen_matpower_mat(path::AbstractString; distinct_pair=false) = error("Not Implemented")

function nbus_matpower_m(path::AbstractString)
    file_string = read(open(path, "r"), String)
    buses = split(file_string, "mpc.bus")[2]
    buses = split(buses, "];")[1]
    return length(split(buses, '\n')) - 2
end

function nbranch_matpower_m(path::AbstractString; distinct_pair=false) 
    nbranch = nothing
    file_string = read(open(path, "r"), String)
    branches = split(file_string, "mpc.branch")[2]
    branches = split(branches, "];")[1]
    branches = split(branches, '\n')[2:end - 1]
    filter!(b -> !startswith(b, "%"), branches)
    if distinct_pair
        branches = [Set(parse.(Int, split(b, '\t')[2:3])) for b in branches]
        nbranch = length(unique(branches))
    else
        nbranch = length(branches)
    end
    return nbranch
end

function ngen_matpower_m(path::AbstractString; distinct_pair=false)
    nbranch = nothing
    file_string = read(open(path, "r"), String)
    branches = split(file_string, "mpc.gen")[2]
    branches = split(branches, "];")[1]
    if distinct_pair
        branches = split(branches, '\n')[2:end - 1]
        branches = [parse(Int, split(b, '\t')[2]) for b in branches]
        nbranch = length(unique(branches))
    else
        nbranch = length(split(branches, '\n')) - 2
    end
    return nbranch
end
