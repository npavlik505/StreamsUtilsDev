database_bl := "$STREAMS_DIR/examples/supersonic_sbli/database_bl.dat"


nv:
	mkdir -p $APPTAINER_TMPDIR

	rm -f nv.sandbox

	taskset -c 0-15 sudo apptainer build --sandbox \
		nv.sandbox \
		"docker://nvcr.io/nvidia/nvhpc:24.7-devel-cuda_multi-ubuntu22.04"

base:
	mkdir -p $APPTAINER_TMPDIR

	rm -f base.sandbox 
	echo $APPTAINER_TMPDIR
	time taskset -c 0-15 sudo -E apptainer build --sandbox --nv base.sandbox base.apptainer
	sudo du -sh base.sandbox

build:
	rm -f streams.sif
	echo $APPTAINER_TMPDIR
	test -e libstreams*.so && rm libstreams*.so || true
	# f2py -m libstreamsMin -h ./libstreamsMin.pyf --overwrite-signature ${STREAMS_DIR}/src/min_api.F90
	# f2py -m libstreamsMod -h ./libstreamsMod.pyf --overwrite-signature ${STREAMS_DIR}/src/mod_api.F90
	# python3 patch_pyf.py
	time taskset -c 0-15 sudo -E apptainer build --nv streams.sif build.apptainer
	du -sh streams.sif



# build a config json file as input to the solver
config_output := "./output/input.json"
#streams_flow_type := "shock-boundary-layer"
streams_flow_type := "boundary-layer"
eval := "./output/eval"
checkpoint := "./output/checkpoint"

config:
	echo {{config_output}}

	# 600, 208, 100
	#--fixed-dt 0.0008439 \

	cargo r -- config-generator {{config_output}} \
		{{streams_flow_type}} \
		--steps 2500 \
		--reynolds-number 250 \
		--mach-number 2.28 \
		--x-divisions 600 \
		--y-divisions 208 \
		--z-divisions 100 \
		--json \
		--x-length 27.0 \
		--y-length 6.0 \
		--z-length 3.8 \
		--rly-wr 2.5 \
		--mpi-x-split 4 \
		--span-average-io-steps 5 \
		--probe-io-steps 0 \
		--python-flowfield-steps 500 \
		--use-python \
		--nymax-wr 201 \
		--sensor-threshold 0.1 \
		adaptive \
			--amplitude 1.0 \
			--slot-start 100 \
			--slot-end 149 \
			--train-episodes 10 \
			--eval-episodes 10 \
			--eval-max-steps 1000 \
			--checkpoint-dir {{checkpoint}}\
			--checkpoint-interval 5 \
			--seed 42 \
			--learning-rate 0.0003 \
			--gamma 0.99 \
			--tau 0.005 \
			--buffer-size 100000 \
			--eval-output {{eval}} \

	cat {{config_output}}



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
