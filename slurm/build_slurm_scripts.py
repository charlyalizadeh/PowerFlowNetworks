import sys
import pathlib
from pathlib import Path

project_dir = Path(sys.argv[1]).resolve()
mpi_script = project_dir.joinpath("scripts", "mpi.jl")
config_path = project_dir.joinpath("data", "configs", "kwargs.jl")
log_dir = project_dir.joinpath("slurm", ".log")
setup_process = [
    "save_basic_features_instances",
    #"save_single_features_instances",
    "save_features_instances",
    "serialize_instances",
    "export_matpowerm_instances"
]
process = [
    "generate_decompositions",
    "merge_decompositions",
    "combine_decompositions",
    "delete_duplicates"
]
slurm_config = {
    "job-name": "PFN",
    "output": log_dir.joinpath("output.txt"),
    "error": log_dir.joinpath("error.txt"),
    "ntasks": 56,
    "partition": "MISC-56c-VERYSHORT"
}
setup_db_config = {
    "LOAD_SCRIPT": '"' + str(project_dir.joinpath("scripts/load_instance_in_db.jl")) + '"',
    "DBPATH": '"' + str(project_dir.joinpath("data/PowerFlowNetworks.sqlite")) + '"',
    "INDIRS_RAWGO": '"' + ','.join([str(p) for p in project_dir.joinpath("data/RAWGO").iterdir()]) + '"',
    "INDIRS_MATPOWERM": '"' + str(project_dir.joinpath("data/MATPOWERM")) + '"'
}
slurm_header = '\n'.join([f"#SBATCH --{k}={v}" for k, v in slurm_config.items()]) + '\n\n'
for p in process:
    path = project_dir.joinpath("slurm", f"{p}.slurm")
    with open(path, "w") as file:
        file.write("#!/bin/sh\n")
        file.write(slurm_header)
        file.write(f"srun julia --project={project_dir} {mpi_script} --process_type {p} --config_key {p} --log_dir {log_dir}\n")

setup_db_path = project_dir.joinpath("slurm", "setup_db.slurm")
setup_db_header = '\n'.join([f"{k}={v}" for k, v in setup_db_config.items()]) + '\n\n'
with open(setup_db_path, "w") as file:
    file.write("#!/bin/sh\n")
    file.write(slurm_header)
    file.write(setup_db_header)
    file.write(f"julia --project=./ $LOAD_SCRIPT --dbpath $DBPATH --indirs_rawgo $INDIRS_RAWGO --indirs_matpowerm $INDIRS_MATPOWERM\n")
    for p in setup_process:
        file.write(f"srun julia --project={project_dir} {mpi_script} --process_type {p} --config_key {p} --log_dir {log_dir}\n")
        file.write(f"julia --project={project_dir} scripts/write_queries.jl\n")
        file.write(f"rm -f queries/*\n")
