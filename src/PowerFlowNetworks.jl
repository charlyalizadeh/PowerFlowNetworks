module PowerFlowNetworks

using Graphs, MetaGraphs
using SQLite, DataFrames
using Dates
using Statistics: mean, median, var
using Serialization
using DataStructures
using Random
using DelimitedFiles
using UUIDs
using SparseArrays
using LinearAlgebra
using Combinatorics
import JSON
import TOML
using MPI
using Polynomials: Polynomial, fit, coeffs
#using Plots
#using StatsPlots


# Solve module
using Logging
using CSV
using Printf
using JuMP
using Mosek
using MosekTools
import Base.Iterators: flatten

mutable struct PowerFlowNetwork
    name::String
    bus::DataFrame
    gen::DataFrame
    branch::DataFrame
    gencost::DataFrame
    baseMVA::Float64
end


include("core.jl")

include("utils/graphs/lbfs.jl")
include("utils/graphs/ischordal.jl")
include("utils/graphs/build_graph.jl")
include("utils/clique_cliquetree.jl")
include("utils/graphs/operators.jl")
include("utils/get_config_toml.jl")

include("io/io.jl")

include("read_features.jl")

include("graphs/graphs.jl")
include("graphs/operations.jl")

include("chordal_extension/chordal_extension/chordal_extension.jl")
include("chordal_extension/merge/merge.jl")
include("chordal_extension/combine/combine.jl")
include("chordal_extension/interpolate/interpolate.jl")

include("solve/solve.jl")

include("db/db.jl")

include("mpi.jl")


PowerFlowNetwork(path::AbstractString, format::AbstractString) = read_network(path, format)
SimpleGraph(network::PowerFlowNetwork) = to_simple_graph(network)

# core
export PowerFlowNetwork
export nbus, nbranch, ngen, is_disjoint, has_bus, has_branch, has_gen,
       has_continuous_index, normalize_index, merge_duplicate_branch!,
       convert_gencost!, has_gencost_index, set_gencost_index!, replace_inf_by!

# utils
export ischordal
export get_nv, get_ne, get_nb_lc
export get_config_toml

# io
export nbranch_unique, ngen_unique
export read_clique, read_cliquetree
export serialize_graph, load_graph
export serialize_network, load_network
export export_network, read_network

# graphs
export Graph
export add_edges_distance!, add_edges_random!, add_edges!
export chordal_extension

# chordal extension
export combine_graph
export merge_dec
export interpolate_graph

# solve
export solve_sdp

# db
## db
export setup_db
export has_opf_tables, count_missing_columns, table_count, nb_instances, nb_decompositions, get_table_ids, get_cholesky_times
export check_sanity, check_sanity_mpi
export delete_db
## instances
export load_in_db_instances!
export save_features_instances!, save_basic_features_instances!, save_single_features_instances!
export serialize_instances!,  delete_duplicates! 
export export_instances!, load_matctr_instances!
#export explore_instances
## decompositions
export generate_decompositions!, merge_decompositions!, combine_decompositions!, interpolate_decompositions!,
       export_db_to_gnndata, solve_decompositions!, check_is_cholesky_decompositions!, set_treshold_solving_time_decompositions!

# mpi
export execute_process_mpi


end
