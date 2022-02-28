get_matpower_cols() = Dict(
    "bus" => ["bus_i", "type", "Pd", "Qd", "Gs", "Bs", "area", "Vm", "Va", "baseKV", "zone", "Vmax", "Vmin"],
    "gen" => ["bus", "Pg", "Qg", "Qmax", "Qmin", "Vg", "mBase", "status", "Pmax", "Pmin", "Pc1", "Pc2", "Qc1min", "Qc1max", "Qc2min", "Qc2max", "ramp_agc", "ramp_10", "ramp_30", "ramp_q", "apf"],
    "branch" => ["fbus", "tbus", "r", "x", "b", "rateA", "rateB", "rateC", "ratio", "angle", "status", "angmin", "angmax"],
    "gencost" => ["model", "startup", "shutdown", "ncost", "cost"]
)

function _row_to_array_matpower_mat(row)
    values = split(strip(row, [';', '\r']), '\t')[2:end]
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
    bus, gen, branch, gencost, baseMVA = nothing, nothing, nothing, nothing, nothing
    data = Dict()
    occursin_pattern = ["mpc.bus", "mpc.gen ", "mpc.branch", "mpc.gencost"]
    occursin_key = ["bus", "gen", "branch", "gencost"]
    pattern_idx = 1
    for (i, f) in enumerate(lines)
        if occursin("mpc.baseMVA", f)
            data["baseMVA"] = parse(Float64, f[15:end - 2])
        elseif occursin(occursin_pattern[pattern_idx], f)
            data[occursin_key[pattern_idx]] = _parse_matrix_matpower_mat(lines, i + 1)
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
