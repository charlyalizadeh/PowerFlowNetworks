# Setup/Load/Insert/Delete
include("setup_db.jl")
include("load_in_db_instances.jl")
include("insert.jl")
include("delete_duplicates.jl")

# Save features
include("features/save_basic_features_instances.jl")
include("features/save_features_instances.jl")
include("features/save_single_features_instances.jl")

# Serialize
include("serialize_instances.jl")

# Generate
include("generate/generate_decompositions.jl")
include("generate/merge_decompositions.jl")
include("generate/combine_decompositions.jl")

# Solve
include("solve/load_matctr_instances.jl")
include("solve/solve_decompositions.jl")

# Export
include("export/export_db_to_gnndata.jl")
include("export/export_instances.jl")

# Infos
include("other/infos.jl")
include("other/check_sanity.jl")
