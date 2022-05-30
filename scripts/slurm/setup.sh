#!/bin/sh

project_dir='/home/charly/Documents/Recherche_SDP/A5/Experiment/PowerFlowNetworks'
data_dir="$project_dir/data"
script_dir="$project_dir/scripts"
min_nv=100
max_nv=2000
config_dir="$project_dir/configs"
default_config_path="$config_dir/defaults.toml"

#julia --project="$project_dir" "$script_dir/julia/db/load_in_db_instances.jl" --toml_config --toml_config_key load_in_db_instances_no_rawgo --toml_config_path "$default_config_path"
#wait
#julia --project="$project_dir" "$script_dir/julia/db/read_basic_features.jl" 
#wait
julia --project="$project_dir" "$script_dir/julia/db/serialize_instances.jl" --min_nv $min_nv --max_nv $max_nv --recompute
wait
#julia --project="$project_dir" "$script_dir/julia/db/read_features.jl" --min_nv $min_nv --max_nv $max_nv
#wait
#julia --project="$project_dir" "$script_dir/julia/solve/load_matctr_instances.jl" 
