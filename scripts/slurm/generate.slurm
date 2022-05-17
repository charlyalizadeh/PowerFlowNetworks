#!/bin/sh
#SBATCH --job-name=PFN
#SBATCH --output=/nfs/homes/charly-kyan.alizadeh/repos/PowerFlowNetworks/.log/generate/output.txt
#SBATCH --error=/nfs/homes/charly-kyan.alizadeh/repos/PowerFlowNetworks/.log/generate/error.txt
#SBATCH --ntasks=40
#SBATCH --partition=COMPUTE

project_dir='/nfs/homes/charly-kyan.alizadeh/repos/PowerFlowNetworks/'
data_dir="$project_dir/data"
script_dir="$project_dir/scripts"
min_nv=1000
max_nv=15000
config_dir="$project_dir/configs"
default_config_path="$config_dir/defaults.toml"


srun julia --project="$project_dir" "$script_dir/julia/decompositions/generate.jl" --toml_config --toml_config_key 0cholesky --min_nv $min_nv --max_nv $max_nv --mpi
wait
srun julia --project="$project_dir" "$script_dir/julia/decompositions/generate.jl" --toml_config --toml_config_key 0minimum_degree --min_nv $min_nv --max_nv $max_nv --mpi
