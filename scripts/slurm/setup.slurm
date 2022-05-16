#!/bin/sh
#SBATCH --job-name=PFN
#SBATCH --output=/nfs/homes/charly-kyan.alizadeh/repos/PowerFlowNetworks/.log/setup/output.txt
#SBATCH --error=/nfs/homes/charly-kyan.alizadeh/repos/PowerFlowNetworks/.log/setup/error.txt
#SBATCH --ntasks=56
#SBATCH --partition=MISC-56c-VERYSHORT

project_dir='/nfs/homes/charly-kyan.alizadeh/repos/PowerFlowNetworks/'
data_dir="$project_dir/data"
script_dir="$project_dir/script"
min_nv=1000
max_nv=15000

julia --project="$project_dir" "$script_dir/julia/db/load_in_db_instances.jl"
wait
srun julia --project="$project_dir" "$script_dir/julia/db/read_basic_features.jl"
wait
srun julia --project="$project_dir" "$script_dir/julia/db/serialize_instances.jl" --min_nv $min_nv --max_nv $max_nv
wait
srun julia --project="$project_dir" "$script_dir/julia/db/read_features.jl" --min_nv $min_nv --max_nv $max_nv
wait
srun julia --project="$project_dir" "$script_dir/julia/solve/load_matctr_instances.jl"
