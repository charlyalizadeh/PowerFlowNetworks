# Setup/Load
include("other/setup_db.jl")
include("other/load_in_db_instances.jl")

# Save features
include("features/save_basic_features_instances.jl")
include("features/save_features_instances.jl")
include("features/save_single_features_instances.jl")

# Serialize
include("other/serialize_instances.jl")

# Generate
include("generate/generate_decompositions.jl")
include("generate/merge_decompositions.jl")
include("generate/combine_decompositions.jl")

# Solve
include("solve/load_matctr_instances.jl")
include("solve/solve_decompositions.jl")

# Other
include("other/insert.jl")
include("other/infos.jl")
include("other/delete_duplicates.jl")
include("other/export_matpowerm.jl")
include("other/check_sanity.jl")
include("other/export.jl")
