function get_blocks(cliques)
    number_elements = length(collect(flatten(cliques)))
    blocks = Array{String,2}(undef, number_elements * 2, 2)
    blocks_list = Dict("B$i" => clique for (i, clique) in enumerate(cliques))
    #println(cliques)
    #println(blocks)
    #println(blocks_list)
    i = 1
    for block in blocks_list
        for vertex in block.second
            blocks[i, 1] = block.first
            blocks[i, 2] = "VOLT_$(vertex)_Re"
            blocks[i + 1, 1] = block.first
            blocks[i + 1, 2] = "VOLT_$(vertex)_Im"
            i += 2
        end
    end
    return blocks
end

function get_cliquetree_mat(cliquetree)
    #cliquetree_mat = Array{String,2}("ERROR", length(cliquetree), 2)
    cliquetree_mat = ones(String, length(cliquetree), 2)
    #println(cliquetree)
    #println(cliquetree_mat)
    for (index, neighbor) in enumerate(cliquetree)
        #println(neighbor)
        #println(cliquetree_mat[index, 1])
        #println(cliquetree_mat[index, 2])
        #println(neighbor[1])
        #println(neighbor[2])
        cliquetree_mat[index, 1] = "B$(neighbor[1])"
        cliquetree_mat[index, 2] =  "B$(neighbor[2])"
    end
    return cliquetree_mat
end

function get_opf_mat(path)
    return readdlm(path, skipstart=1)
end

function get_opf_ctr(path)
    return readdlm(path, skipstart=1)
end

function read_data(cliques, cliquetree, path_opf_ctr, path_opf_mat)
    return get_blocks(cliques), get_cliquetree_mat(cliquetree),
           get_opf_ctr(path_opf_ctr), get_opf_mat(path_opf_mat)
end

function read_mosek_log(log_file)
    search = ["nb_coupling_constraints primal :",
              "  Constraints            :",
              "Julia resolution time :",
              "Objective value: ",
              "memory : "]
    count_iter = false
    values = zeros(length(search) + 1)
    index = 1
    for line in readlines(log_file)
        if occursin(search[index], line)
            values[index] = parse(Float64, split(line, ':')[2])
            index < length(search) - 1 && (index += 1)
        elseif occursin("ITE", line)
            count_iter = true
            continue
        elseif occursin("Optimizer terminated.", line)
            count_iter = false
        end
        count_iter && (values[end] += 1)
    end
    return values
    #lines = readlines(log_file)
    #i = 1
    #while split(lines[i], ':')[1]!= "nb_coupling_constraints primal " && split(lines[i], ':')[1]!="nb_coupling_constraints "
    #    i+=1
    #end
    #nlc = parse(Int, split(lines[i], ':')[2])
    #while split(lines[i], ':')[1] != "  Constraints            "
    #    i+=1
    #end
    #n_total_constraints = parse(Int,split(lines[i], ':')[2])
    #m = n_total_constraints - nlc
    #while split(lines[i], ':')[1] != "Optimizer terminated. Time" && i < length(lines)
    #    i+=1
    #end
    #time = split(lines[i], ':')[2][2:end]
    #nb_iter = split(lines[i-1], ' ')[1]
    #objective = lines[i+2][18:end]
    #return time, nb_iter, objective, m, nlc
    return values
end
