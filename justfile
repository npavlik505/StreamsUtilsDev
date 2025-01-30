database_bl := "$STREAMS_DIR/examples/supersonic_sbli/database_bl.dat"

nv:
	mkdir -p $APPTAINER_TMPDIR

	rm -f nv.sif

	sudo apptainer build \
		nv.sif \
		"docker://nvcr.io/nvidia/nvhpc:22.1-devel-cuda_multi-ubuntu20.04"

base:
	mkdir -p $APPTAINER_TMPDIR

	rm -f base.sif 
	echo $APPTAINER_TMPDIR
	time sudo -E apptainer build --nv base.sif base.apptainer
	du -sh base.sif

build:
	rm -f streams.sif
	echo $APPTAINER_TMPDIR
	time sudo -E apptainer build --nv streams.sif build.apptainer
	du -sh streams.sif

# build a config json file as input to the solver
config_output := "./output/input.json"
#streams_flow_type := "shock-boundary-layer"
streams_flow_type := "boundary-layer"

config:
	echo {{config_output}}

	# 600, 208, 100
	#--fixed-dt 0.0008439 \

	cargo r -- config-generator {{config_output}} \
		{{streams_flow_type}} \
		--steps 10 \
		--reynolds-number 250 \
		--mach-number 0. \
		--x-divisions 300 \
		--y-divisions 300 \
		--z-divisions 100 \
		--json \
		--x-length 3.0 \
		--y-length 3.0 \
		--rly-wr 0.5 \
		--mpi-x-split 1 \
		--span-average-io-steps 1 \
		--python-flowfield-steps 1000 \
		--use-python \
		--nymax-wr 99 \
		--sensor-threshold 0.1 \
		constant \
			--amplitude 1.0 \
			--slot-start 100 \
			--slot-end 200

	cat {{config_output}}

jet_validation_base_path := "./distribute/jet_validation/"

jet_validation_number := "20"
jet_validation_batch_name := "jet_validation_" + jet_validation_number
jet_valiation_output_folder := jet_validation_base_path + jet_validation_batch_name

jet_validation:
	echo {{jet_valiation_output_folder}}

	# 600, 208, 100
	#--steps 10000 \

	cargo r -- cases jet-validation \
		{{jet_valiation_output_folder}} \
		--batch-name {{jet_validation_batch_name}} \
		--solver-sif ./streams.sif \
		--steps 50000 \
		--database-bl {{database_bl}} \
		--matrix @karlik:matrix.org

variable_dt_base_path := "./distribute/variable_dt/"

variable_dt_case_number := "01"
variable_dt_batch_name := "variable_dt_" + variable_dt_case_number
variable_dt_output_folder := variable_dt_base_path + variable_dt_batch_name

variable_dt:
	echo {{jet_valiation_output_folder}}

	# 600, 208, 100
	#--steps 10000 \

	cargo r -- cases variable-dt \
		{{variable_dt_output_folder}} \
		--batch-name {{variable_dt_batch_name}} \
		--solver-sif ./streams.sif \
		--steps 20000 \
		--database-bl {{database_bl}} \
		--matrix @karlik:matrix.org

ai_institute_base_path := "./distribute/ai_institute/"
ai_institute_case_number := "01"
ai_institute_batch_name := "ai_institute_" + ai_institute_case_number
ai_institute_output_folder := ai_institute_base_path + ai_institute_batch_name

ai_institute:
	echo {{ai_institute_output_folder}}

	cargo r -- cases ai-institute \
		{{ai_institute_output_folder}} \
		--batch-name {{ai_institute_batch_name}} \
		--solver-sif ./streams.sif \
		--steps 50000 \
		--database-bl {{database_bl}} \
		--matrix @karlik:matrix.org

run:
	cargo r -- run-local \
		--workdir ./output/ \
		--config ./output/input.json \
		--database {{database_bl}} \
		--python-mount $STREAMS_DIR/streamspy \
		16

# get a shell inside the container
# requires the ./output directory (with its associated folders) to be created, 
# and a ./streams.sif file to be made
shell:
	apptainer shell --nv --bind ./output/distribute_save:/distribute_save,./output/input:/input ./streams.sif

# get a shell inside the container
# and bind your $STREAMS_DIR environment variable to the folder
# /streams
local:
	apptainer shell --nv --bind $STREAMS_DIR:/streams ./base.sif

vtk:
	cargo r --release -- hdf5-to-vtk ./output/distribute_save

base_animate_folder := "./distribute/ai_institute/ai_institute_01/ai_institute_01/"

animate:
	cargo r --release -- animate \
		"{{base_animate_folder}}/no_actuator" \
		--decimate 5

	#cargo r --release -- animate \
	#	"{{base_animate_folder}}/sinusoidal" \
	#	--decimate 5
