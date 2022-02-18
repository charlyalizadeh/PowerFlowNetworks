get_matpower_cols() = Dict(
    "bus" => ["bus_i", "type", "Pd", "Qd", "Gs", "Bs", "area", "Vm", "Va", "baseKV", "zone", "Vmax", "Vmin"],
    "gen" => ["bus", "Pg", "Qg", "Qmax", "Qmin", "Vg", "mBase", "status", "Pmax", "Pmin", "Pc1", "Pc2", "Qc1min", "Qc1max", "Qc2min", "Qc2max", "ramp_agc", "ramp_10", "ramp_30", "ramp_q", "apf"],
    "branch" => ["fbus", "tbus", "r", "x", "b", "rateA", "rateB", "rateC", "ratio", "angle", "status", "angmin", "angmax"],
    "gencost" => ["model", "startup", "shutdown", "ncost", "cost"]
)

function _matpower_row_to_array(row)
    values = split(strip(row, [';', '\r']), '\t')[2:end]
    array = map(x -> parse(Float64, x), values) 
    return array
end

function _read_matpower_mat(lines, start)
    nb_cols = length(split(lines[start], '\t')) - 1
    current_line = start
    matrix = nothing
    while !occursin("];", lines[current_line])
        if isnothing(matrix)
            matrix = transpose(_matpower_row_to_array(lines[current_line]))
        else
            matrix = [matrix; transpose(_matpower_row_to_array(lines[current_line]))]
        end
        current_line += 1
    end
    return matrix
end

function get_matpower_data(path::AbstractString)
    file_string = read(open(path, "r"), String)
    lines = split(file_string, '\n')
    bus, gen, branch, gencost = nothing, nothing, nothing, nothing
    for (i, f) in enumerate(lines)
        if occursin("mpc.bus", f)
            bus = _read_matpower_mat(lines, i + 1)
        elseif occursin("mpc.gen ", f)
            gen = _read_matpower_mat(lines, i + 1)
        elseif occursin("mpc.branch", f)
            branch = _read_matpower_mat(lines, i + 1)
        elseif occursin("mpc.gencost", f)
            gencost = _read_matpower_mat(lines, i + 1)
        end
    end
    return bus, gen, branch, gencost
end

function read_matpower(path::AbstractString)
    bus, gen, branch, gencost = get_matpower_data(path)
    return PowerFlowNetwork(bus, gen, branch, gencost)
end
