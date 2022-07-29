# General
include("db/setup_db.jl")
include("db/insert.jl")
include("db/infos.jl")
include("db/check_sanity.jl")
include("db/delete_db.jl")

# Instances
include("instances/export_instances.jl")
include("instances/load_in_db_instances.jl")
include("instances/save_basic_features_instances.jl")
include("instances/save_features_instances.jl")
include("instances/save_single_features_instances.jl")
include("instances/serialize_instances.jl")
#include("instances/explore_instances.jl")

# Decompositions
include("decompositions/combine_decompositions.jl")
include("decompositions/interpolate_decompositions.jl")
include("decompositions/delete_duplicates.jl")
include("decompositions/export_db_to_gnndata.jl")
include("decompositions/generate_decompositions.jl")
include("decompositions/load_matctr_instances.jl")
include("decompositions/merge_decompositions.jl")
include("decompositions/solve_decompositions.jl")
include("decompositions/check_is_cholesky_decompositions.jl")
