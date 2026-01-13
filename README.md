# DAFOAM + pyoptsparse + pySNOPT for Apptainer HPC

## Overview

This repository provides definitions and instructions on setting up a containerized DAFoam installation on a HPC system. 

* DAFOAM from dafoam/opt-packages:v3.1.2
* pyoptsparse v2.9.1
* Optional support for SNOPT (licensed, not distributed)

### Dockerhub

The public base image (without SNOPT) is available on DockerHub:

[![Docker Image](https://img.shields.io/docker/v/connorourke/dafoam_pyoptsparse?label=DockerHub)](
https://hub.docker.com/r/connorourke/dafoam_pyoptsparse)

containing:

* DAFOAM from dafoam/opt-packages:v3.1.2
* pyoptsparse v2.9.1

Base image is public and SNOPT-free, licensed SNOPT support can be enabled locally on an HPC system using Apptainer and following the instructions.


### Apptainer Build

The Apptainer definition file used to enable SNOPT on HPC systems:

- [`dafoam_pyoptsparse_snopt.def`](
  https://github.com/connorourke/dafoam_pysnopt_apptainer/blob/main/dafoam_pyoptsparse_snopt.def
)

To rebuild the image with pySNOPT enabled first ensure apptainer is installed and loaded, e.g.:

```
module load apptainer
```

Then run (for a system with FUSE)

```
apptainer build dafoam_pyoptsparse_snopt.sif dafoam_pyoptsparse_pysnopt.def
```

or without FUSE create a sandbox:

```
apptainer build --sandbox dafoam_pyoptsparse_snopt_sandbox dafoam_pyoptsparse_pysnopt.def
```

in the command line. The apptainer definition expects to find in the working directory:

```
pySNOPT/
└── source/
```

To run the container interactively with a local simulation folder (`code_testing_multimesh`) bind mounted (from an image created with FUSE):

```
apptainer exec \
  --bind $PWD/code_testing_multimesh:/workspace \
  dafoam_pyoptsparse_snopt.sif \
  bash
```

or with the sandbox:

```
apptainer exec   --bind $PWD/code_testing_multimesh:/workspace  --pwd /home/dafoamuser/dafoam   dafoam_pyoptsparse_snopt_sandbox bash
```


Inside the container:

```
cd /workspace
. /home/dafoamuser/dafoam/loadDAFoam.sh
python mpirun -np 4 sample_run.py
```

An slurm submission script to run the an example `sample_script.py` is [`slurm_submit_script.sh`](
  https://github.com/connorourke/dafoam_pysnopt_apptainer/blob/main/slurm_submit_script.sh
) included:

```
#!/bin/bash
#SBATCH --job-name=dafoam
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --time=02:00:00
#SBATCH --partition=batch
#SBATCH --output=dafoam.out

module load apptainer

SANDBOX=Apptainer/dafoam_pyoptsparse_snopt_sandbox
CASE_DIR=$SLURM_SUBMIT_DIR/code_testing_multimesh


cd $SLURM_SUBMIT_DIR
apptainer exec --bind $CASE_DIR:/workspace $SANDBOX bash -c "
  . /home/dafoamuser/dafoam/loadDAFoam.sh; cd /workspace; 
  mpirun -np 4 python /workspace/sample_run.py
"
```
