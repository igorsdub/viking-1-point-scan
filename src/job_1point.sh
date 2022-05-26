#!/bin/bash
#SBATCH --job-name=xxxx_1d                      # Job name
#SBATCH --mail-type=BEGIN,END,FAIL              # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=username@york.ac.uk         # Where to send mail  
#SBATCH --ntasks=1                              # Run on a single CPU
#SBATCH --mem=100mb                             # Job memory request
#SBATCH --time=00:45:00                         # Time limit hrs:min:sec
#SBATCH --output=logs/scan_1point.%A.%a.log     # Standard output
#SBATCH --error=errors/scan_1point.%x.%j.err    # Error output
#SBATCH --account=project-account-name          # Project account
#SBATCH --array=1-100                           # Array for residue numbers to scan 

# Check if ffile has been submitted
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <pdb-filepath> <cutoff>"
    echo "Example: $0 pdb/1c3b_1.pdb 8.0"
    exit 1
fi

PDB_FILEPATH=$1
CUTOFF=$2
RESIDUE_NUM=$SLURM_ARRAY_TASK_ID

# Load Fortran compiler
module load toolchain/foss/2018b

echo My working directory is `pwd`
echo Running DDPT job index $SLURM_ARRAY_TASK_ID, on host:
echo -e '\t'`hostname` at `date`
echo

time ./scan_1point.sh $PDB_FILEPATH $CUTOFF $RESIDUE_NUM
  
echo
echo Job completed at `date`
