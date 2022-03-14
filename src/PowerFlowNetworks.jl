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

mutable struct PowerFlowNetwork
    bus::DataFrame
    gen::DataFrame
    branch::DataFrame
    baseMVA::Float64
end


include("core.jl")
include("utils/graphs/lbfs.jl")
include("utils/graphs/ischordal.jl")
include("utils/graphs/build_graph.jl")
include("utils/clique_cliquetree.jl")
include("io/read.jl")
include("read_features.jl")
include("graphs/graphs.jl")
include("graphs/operations.jl")
include("db/setup_db.jl")
include("db/infos.jl")
include("db/inserts.jl")
include("utils/graphs/operators.jl")
include("decompositions/chordal_extension/chordal_extension.jl")
include("decompositions/merge/merge.jl")
include("db/operations.jl")


PowerFlowNetwork(path::AbstractString, format::AbstractString) = read_network(path, format)
SimpleGraph(network::PowerFlowNetwork) = to_simple_graph(network)

export nbus, nbranch, ngen, is_disjoint, has_bus, has_branch, has_gen,
       has_continuous_index, normalize_index, merge_duplicate_branch!
export ischordal
export nbranch_unique, ngen_unique
export PowerFlowNetwork
export Graph
export add_edges_distance!, add_edges_random!, add_edges!
export setup_db
export has_opf_tables, count_missing_columns, table_count
export load_instance!
export chordal_extension
export merge_dec
export save_features_instances!, save_basic_features_instances!, save_single_features_instances!,
       serialize_instances!, generate_decompositions!, merge_decompositions!, check_chordality_decompositions,
       check_connectivity_instances, check_selfloops

end
