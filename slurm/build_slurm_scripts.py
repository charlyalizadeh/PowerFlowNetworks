import sys
import pathlib
from pathlib import Path

project_dir = Path(sys.argv[1]).resolve()
mpi_script = project_dir.joinpath("scripts", "mpi.jl")
config_path = project_dir.joinpath("data", "configs", "kwargs.jl")
log_dir = project_dir.joinpath("slurm", ".log")
process = [
    "save_basic_features_instances",
    "save_single_features_instances",
    "save_features_instances",
    "serialize_instances",
    "generate_decompositions",
    "merge_decompositions",
    "combine_decompositions",
]
slurm_config = {
    "job-name": "PFN",
    "output": log_dir.joinpath("output.txt"),
    "error": log_dir.joinpath("error.txt"),
    "ntasks": 40,
    "cpus-per-task": 2,
    "mem-per-cpu": 12800,
}
slurm_header = '\n'.join([f"#SBATCH --{k}={v}" for k, v in slurm_config.items()]) + '\n\n'
for p in process:
    path = project_dir.joinpath("slurm", f"{p}.slurm")
    with open(path, "w") as file:
        file.write("#!/bin/sh\n")
        file.write(slurm_header)
        file.write(f"julia --project={project_dir} {mpi_script} --process_type {p} --config_key {p} --log_dir {log_dir}")
