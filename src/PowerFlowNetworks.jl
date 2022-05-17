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

include("decompositions/chordal_extension/chordal_extension.jl")
include("decompositions/merge/merge.jl")
include("decompositions/combine/combine.jl")

include("solve/solve.jl")

include("db/db.jl")

include("mpi.jl")


PowerFlowNetwork(path::AbstractString, format::AbstractString) = read_network(path, format)
SimpleGraph(network::PowerFlowNetwork) = to_simple_graph(network)

# core
export PowerFlowNetwork
export nbus, nbranch, ngen, is_disjoint, has_bus, has_branch, has_gen,
       has_continuous_index, normalize_index, merge_duplicate_branch!,
       convert_gencost!, has_gencost_index, set_gencost_index!

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

# decompositions
export combine_graph
export merge_dec

# solve
export solve_sdp

# db
export setup_db
export has_opf_tables, count_missing_columns, table_count, nb_instances, nb_decompositions, get_table_ids
export load_in_db_instances!
export save_features_instances!, save_basic_features_instances!, save_single_features_instances!
export generate_decompositions!, merge_decompositions!, combine_decompositions!
export serialize_instances!, check_sanity, check_sanity_mpi, delete_duplicates!, export_instances!, load_matctr_instances!,
       export_db_to_gnndata
export solve_decompositions!

# mpi
export execute_process_mpi


end
