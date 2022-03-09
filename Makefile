MIN_NV = 1000
MAX_NV = 15000
DBPATH = data/PowerFlowNetworks.sqlite
_INDIRS_RAWGO = $(wildcard data/RAWGO/*)
_SOURCE_TYPE = RAWGO MATPOWER-M
_INDIRS_MATPOWERM = data/MATPOWER
space = $(eval) $(eval)
comma := ,
SERIALIZE_PATH = data/networks_serialize

SOURCE_TYPE = $(subst $(space),$(comma),$(_SOURCE_TYPE))
INDIRS_RAWGO = $(subst $(space),$(comma),$(_INDIRS_RAWGO))
INDIRS_MATPOWERM = $(subst $(space),$(comma),$(_INDIRS_MATPOWERM))

download_data:
	python scripts/download_data.py

check_raw_go_dirs:
	python scripts/check_raw_go_dirs.py

load_instance:
	julia --project=./ scripts/load_instance.jl --dbpath $(DBPATH) --indirs_rawgo $(INDIRS_RAWGO) --indirs_matpowerm $(INDIRS_MATPOWERM)

check_read_pfn:
	julia --project=./ scripts/check_read_pfn.jl --dbpath $(DBPATH) --source_type $(SOURCE_TYPE)

read_basic_features:	
	julia --project=./ scripts/read_basic_features.jl --dbpath $(DBPATH)

read_features:	
	julia --project=./ scripts/read_features.jl --min_nv $(MIN_NV) --max_nv $(MAX_NV)

serialize:
	julia --project=./ scripts/serialize_instances.jl --dbpath $(DBPATH) --min_nv $(MIN_NV) --max_nv $(MAX_NV) --serialize_path $(SERIALIZE_PATH)

runtest:
	julia --project=./ test/runtest.jl

process_data: read_basic_features read_features

load_and_process: load_instance read_basic_features read_features serialize
