#!/usr/bin/env python3
"""
Bad code, but it works, don't have the time/motivation to make a nice interface
"""

import pathlib
from pathlib import Path
from slurm_job import SlurmJobPFN

choices = {
        "instances": {
            "load_in_db": ["indirs_rawgo", "indirs_matpowerm"],
            "save_basic_features": ["recompute"],
            "save_features": ["min_nv", "max_nv", "recompute"],
            "serialize": ["min_nv", "max_nv", "recompute", "networks_path", "graphs_path"],
            "load_matctr": ["min_nv", "max_nv", "out"]
        },
        "decompositions": {
            "generate": ["min_nv", "max_nv", "extension_alg", "cliques_path", "cliquetrees_path", "graphs_path", "preprocess_path", "preprocess_key"],
            "merge": ["min_nv", "max_nv", "heuristic", "heuristic_switch", "treshold_name"],
            "combine": [], #TODO
            "solve": ["min_nv", "max_nv", "recompute", "cholesky"],
            "delete_duplicates": [],
            "export_to_gnndata": ["out"]
        },
        "db": {
            "check_sanity": ["min_nv", "max_nv", "table", "check"],
            "delete": []
        },
        "write script": None
}


def get_int_input(prompt, min_value=0, max_value=100):
    choice = -1
    while choice == -1:
        try:
            choice = int(input(prompt))
            if choice < min_value or choice >= max_value:
                print(f"Please enter a value between {min_value} and {max_value}")
                choice = -1
        except ValueError:
            print("Invalid input.")
            choice = -1
    return choice


class SlurmJobPFN_TUI:
    def __init__(self, project_dir):
        self.project_dir = Path(project_dir).resolve()
        self.log_out = open(self.project_dir.joinpath("scripts/.slurm_log.txt"), "a")
        self.job = None

    def write_to_log(self, log):
        self.log_out.write(log)

    def run_setup(self):
        job_name = input("Job name:")
        ntasks = get_int_input("Number of tasks:", min_value=1, max_value=1000)
        partition = input("Partition:")
        self.job = SlurmJobPFN(job_name, ntasks, partition, self.project_dir)

    def run_choices(self, choices, previous_choice=""):
        if previous_choice != "":
            prompt = f"Choose a command for {previous_choice}:\n"
        else:
            prompt = "Choose a subject:\n"
        prompt += ''.join([f"{i}. {c}\n" for i, c in enumerate(choices.keys())])
        print(prompt)
        choice = get_int_input("", 0, len(choices))
        choice = list(choices.keys())[choice]
        if choice == "write script":
            self.job.write_to_slurm(self.project_dir.joinpath(f"scripts/slurm/{self.job.job_name}.slurm"))
            return False
        elif type(choices[choice]) == dict:
            self.run_choices(choices[choice])
        else:
            self.setup_kwargs(previous_choice, choice, choices[choice])
        return True

    def setup_kwargs(self, subject, command, kwargs_names):
        print("Setting the options for {subject}:{command}")
        kwargs = {}
        prompt = ''.join([f"{i}. {c}\n" for i, c in enumerate(kwargs_names + ["Done"])])
        choice = -1
        while True:
            print("Options to set (if an option is not set, will use the default option):")
            print(prompt)
            choice = get_int_input("", 0, len(kwargs_names) + 1)
            if choice == len(kwargs_names):
                break
            else:
                value = input(f"Value for {kwargs_names[choice]}: ")
                kwargs[kwargs_names[choice]] = value
        self.job.add_srun_pfn(subject, command, True, **kwargs)

    def run(self):
        self.run_setup()
        while self.run_choices(choices):
            pass

tui = SlurmJobPFN_TUI("./")
tui.run()
