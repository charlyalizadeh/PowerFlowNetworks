import re
import pathlib
from pathlib import Path
from raw_go_const import archives_dir


rawgo_dir = Path("./data/RAWGO")
network_dirs = [Path(rawgo_dir, p) for p in archives_dir.values()]

scenarios_paths = []
for path in network_dirs:
    for d in path.iterdir():
        if d.is_dir():
            for scenario in d.iterdir():
                scenario = str(scenario)
                if scenario.startswith("scenario"):
                    matched = bool(re.match("scenario_([0-9])+"))
                    scenarios_paths.append((scenario, matched))

is_valid = all([s[1] for s in scenarios_paths])
if is_valid:
    print("All scenario directories names are valid.")
else:
    nb_invalid = sum([not s[1] for s in scenarios_paths])
    print("{nb_invalid} / {len(scenario_paths)} invalid path(s)")
    for path, matched in scenarios_paths:
        if not matched:
            print(path)
