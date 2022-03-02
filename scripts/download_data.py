import wget
import shutil
import os
import pathlib
import subprocess
from raw_go_const import urls_archives, archives_ndirs, archives_dir


# RAWGO
pathlib.Path("data/RAWGO").mkdir(parents=True, exist_ok=True)
archives_path = pathlib.Path("data/archives")
archives_path.mkdir(parents=True, exist_ok=True)


for url, zipfile in urls_archives.items():
    print(f"Downloading {zipfile}")
    if "Challenge_1" in zipfile:
        subprocess.run(["wget", url])
    else:
        filename = wget.download(url)
for filename in archives_dir.keys():
    shutil.move(filename, archives_path)

for filename, network_directory in archives_ndirs.items():
    print(f"Extracting {filename}")
    archive = os.path.join(archives_path, filename)
    dst = os.path.join("data/RAWGO/", archives_dir[filename])
    pathlib.Path(dst).mkdir(parents=True, exist_ok=True)
    if network_directory is None:
        shutil.unpack_archive(archive, dst)
    else:
        shutil.unpack_archive(archive)
        for directory in network_directory:
            for f in pathlib.Path(directory).iterdir():
                shutil.move(f, dst)
            shutil.rmtree(directory.split('/')[0])

shutil.rmtree('__MACOSX')

# MATPOWER
if not pathlib.Path("data/archives/matpower7.1.zip").exists():
    print("The matpower archive version 7.1 is not present under `data/archives/`. Please download the matpower archive manually.")
else:
    pathlib.Path("data/MATPOWER").mkdir(parents=True, exist_ok=True)
    shutil.unpack_archive('data/archives/matpower7.1.zip')
    for filename in pathlib.Path('matpower7.1/data').iterdir():
        dst = pathlib.Path('data/', 'MATPOWER/')
        shutil.move(filename, dst)
    shutil.rmtree('matpower7.1')
