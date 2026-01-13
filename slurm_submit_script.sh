#!/bin/bash
#SBATCH --job-name=dafoam
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --time=02:00:00
#SBATCH --partition=batch
#SBATCH --output=dafoam.out
#SBATCH --qos=expert

module load apptainer

SANDBOX=Apptainer/dafoam_pyoptsparse_snopt_sandbox
CASE_DIR=$SLURM_SUBMIT_DIR/code_testing_multimesh


cd $SLURM_SUBMIT_DIR
apptainer exec --bind $CASE_DIR:/workspace $SANDBOX bash -c "
  . /home/dafoamuser/dafoam/loadDAFoam.sh; cd /workspace; 
  mpirun -np 4 python /workspace/sample_run.py
"
