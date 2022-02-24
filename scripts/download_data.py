import wget
import shutil
import os
import pathlib
import subprocess


# RAW-GO
pathlib.Path("data/RAW_GO").mkdir(parents=True, exist_ok=True)
pathlib.Path("data/archives").mkdir(parents=True, exist_ok=True)

urls = {
    "C2T3": "https://gocompetition.energy.gov/sites/default/files/C2T3_20210716.zip",
    "C2T2": "https://gocompetition.energy.gov/sites/default/files/C2T2_20210520.zip",
    "C2T1": "https://gocompetition.energy.gov/sites/default/files/C2T1_20210122.zip",
    "C2SPN": "https://gocompetition.energy.gov/sites/default/files/SandboxData_C2S9_20210720a.zip",
    "C2S7N": "https://gocompetition.energy.gov/sites/default/files/SandboxData_C2S7_20210305.zip",
    "C2S6N00617": "https://gocompetition.energy.gov/sites/default/files/SandboxData_C2S6_C2S6N00617_20210201.zip",
    "C2S6": "https://gocompetition.energy.gov/sites/default/files/SandboxData_C2S6_20201122.zip",
    "Challenge_1_Real_Time": "https://dtn2.pnl.gov/arpacomp/F1/Challenge_1_Final_Event_Real-Time.zip",
    "Challenge_1_Offline": "https://dtn2.pnl.gov/arpacomp/F1/Challenge_1_Final_Event_Offline.zip",
    "Challenge_1_Trial_3": "https://gocompetition.energy.gov/file/1089/download?token=62Sq3xQs",
    "Challenge_1_Trial_2": "https://gocompetition.energy.gov/file/1076/download?token=cUvALaUC",
    "Challenge_1_T1_39S": "https://gocompetition.energy.gov/file/1025/download?token=YP_VwqsX",
    "Challenge_1_Original_Dataset_2": "https://gocompetition.energy.gov/file/648/download?token=_LM4nQMj",
    "Challenge_1_Original_Dataset_1": "https://gocompetition.energy.gov/file/637/download?token=GpVSh80R",
    "C2FE": "https://gocompetition.energy.gov/sites/default/files/C2FE_20210813.zip"
}

network_directories = {
    "Challenge_1_Final_Event_Offline.zip": ["Challenge_1_Final_Offline/"],
    "Challenge_1_Final_Event_Real-Time.zip": ["Challenge_1_Final_Real-Time/"],
    "C2T3_20210716.zip": ["C2T3_20210716/"],
    "C2T2_20210520.zip": ["C2_Trial_2/"],
    "C2T1_20210122.zip": None,
    "SandboxData_C2S9_20210720a.zip": None,
    "SandboxData_C2S7_20210305.zip": None,
    "SandboxData_C2S6_C2S6N00617_20210201.zip": None,
    "SandboxData_C2S6_20201122.zip": None,
    "Trial3.zip": ["Trial_3_Real-Time/", "Trial_3_Offline/"],
    "T2_10x14.zip": ["Trial2/Trial2_Offline-10x14/"],
    "T1-39S.zip": ["T1S3_Offline/", "T1S3_Real-Time/"],
    "Original_Dataset_1-5.zip": ["Original_Dataset_Real-Time_Edition_1/", "Original_Dataset_Offline_Edition_1/"],
    "Original_Dataset_2-3.zip": ["Original_Dataset_Real-Time_Edition_2/", "Original_Dataset_Offline_Edition_2/"],
    "C2FE_20210813.zip": None
}

dirnames = {
    "Challenge_1_Final_Event_Offline.zip": "Challenge_1_Offline",
    "Challenge_1_Final_Event_Real-Time.zip": "Challenge_1_Real_Time",
    "C2T3_20210716.zip": "C2T3",
    "C2T2_20210520.zip": "C2T2",
    "C2T1_20210122.zip": "C2T1",
    "SandboxData_C2S9_20210720a.zip": "C2SPN",
    "SandboxData_C2S7_20210305.zip": "C2S7N",
    "SandboxData_C2S6_C2S6N00617_20210201.zip": "C2S6N00617",
    "SandboxData_C2S6_20201122.zip": "C2S6",
    "Trial3.zip": "Challenge_1_Trial_3",
    "T2_10x14.zip": "Challenge_1_Trial_2",
    "T1-39S.zip": "Challenge_1_T1_39S",
    "Original_Dataset_1-5.zip": "Challenge_1_Original_Dataset_1",
    "Original_Dataset_2-3.zip": "Challenge_1_Original_Dataset_2",
    "C2FE_20210813.zip": "C2FE"
}

#for key, val in urls.items():
#    print(f"Downloading {key}")
#    if key in ("Challenge_1_Real_Time", "Challenge_1_Offline"):
#        subprocess.run(["wget", val])
#    else:
#        filename = wget.download(val)
archives_dir = "data/archives/"
#for filename in dirnames.keys():
#    shutil.move(filename, archives_dir)

for filename, network_directory in network_directories.items():
    print(f"Extracting {filename}")
    archive = os.path.join(archives_dir, filename)
    dst = os.path.join("data/RAW_GO/", dirnames[filename])
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
