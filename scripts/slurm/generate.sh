#!/bin/sh

project_dir='/home/charly/Documents/Recherche_SDP/A5/Experiment/PowerFlowNetworks'
data_dir="$project_dir/data"
script_dir="$project_dir/scripts"
config_dir="$project_dir/configs"


julia --project="$project_dir" "$script_dir/julia/decompositions/generate.jl" --toml_config --toml_config_key 100_500.0cholesky
wait
julia --project="$project_dir" "$script_dir/julia/decompositions/generate.jl" --toml_config --toml_config_key 100_500.0minimum_degree
wait
julia --project="$project_dir" "$script_dir/julia/decompositions/merge.jl" --toml_config --toml_config_key 100_500.merge_molzahn10
