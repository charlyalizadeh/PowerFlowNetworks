include("read_data.jl")
include("build_mosek.jl")

function get_valid_log(instance_name, outpath=joinpath("data", "mosek_logs", instance_name))
    index =  0
    file =  "$instance_name.log"
    while ispath(joinpath(outpath, file))
        index += 1
        file = "$(instance_name)_$(index).log"
    end
    return file
end

"""
    solve_sdp(instance_name, cliques, cliquetree, path_opf_ctr, path_opf_mat; time_limit=100000.0)

Solve an SDP cliques decompositions.
"""
function solve_sdp(instance_name, cliques, cliquetree, path_opf_ctr, path_opf_mat; time_limit=100000.0)
    REPO = "OPF"
    objscale = 4 #0 if no scaling
    originalSTDOUT = stdout
    outpath = joinpath("data/mosek_logs", instance_name)
    isdir(outpath) || mkpath(outpath)
    log_file = get_valid_log(instance_name, outpath)
    outlog = open(joinpath(outpath,log_file), "w")
    redirect_stdout(outlog)
    println("objscale : 10^(-$objscale) \n")
    Xoptimal, obj, status, time, mem = sdp_model_solver_to_specify(cliques, cliquetree, path_opf_ctr, path_opf_mat, 10.0^(-objscale); time_limit=time_limit)
    println("time : $time \n memory : $mem")
    close(outlog)
    redirect_stdout(originalSTDOUT)
    nb_lc, m, time, objective, nb_iter = read_mosek_log(joinpath(outpath, log_file))
    #time, nb_iter, objective, m, nlc = read_mosek_log(joinpath(outpath, log_file))
    return time, nb_iter, joinpath(outpath, log_file), objective, m, nb_lc
end
