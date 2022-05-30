import pathlib
from pathlib import Path

class SlurmJob:
    def __init__(self, job_name, output, error, ntasks, partition):
        self.job_name = job_name
        self.output = output
        self.error = error
        self.ntasks = ntasks
        self.partition = partition
        self.srun_commands = []

    def add_srun(self, srun_command, wait=True):
        self.srun_commands.append(srun_command)
        if wait:
            self.srun_commands.append("wait")

    def write_to_slurm(self, out):
        setup = f"""#!/bin/sh
#SBATCH --job-name={self.job_name}
#SBATCH --output={self.output}
#SBATCH --error={self.error}
#SBATCH --ntasks={self.ntasks}
#SBATCH --partition={self.partition}\n
"""
        with open(out, "w") as io:
            io.write(setup)
            for srun_command in self.srun_commands:
                io.write(srun_command)
                io.write("\n")


class SlurmJobPFN(SlurmJob):
    def __init__(self, job_name, ntasks, partition, project_dir):
        self.project_dir = Path(project_dir).resolve()
        self.pfn_script = Path(f"{project_dir}/scripts/pfn.jl").resolve()
        output = Path(project_dir).joinpath(f".log/slurm/{job_name}/output.txt")
        error = Path(project_dir).joinpath(f".log/slurm/{job_name}/error.txt")
        super().__init__(job_name, output, error, ntasks, partition)

    def add_srun_pfn(self, subject, command, wait=True, **kwargs):
        srun_command = f"julia --project={self.project_dir} {self.pfn_script} {subject}:{command} "
        for k, v in kwargs.items():
            srun_command += f"--{k} {v} "
        self.add_srun(srun_command, wait)


