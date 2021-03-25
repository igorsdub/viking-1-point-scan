#!/bin/bash
# Runs 1-point mutational scan for passed residue number

if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <pdb-filepath> <cutoff> <residue-number>"
    echo "Example: $0 pdb/1c3b.1.pdb 8.0 145"
    exit 1
fi

if [ "$3" -lt 1 ]; then
    echo "Residue should be >= 1"
    exit 1
fi

echo "PDB filepath:"    $1
echo "Cut-off (angs):"  $2
echo "Residue number:"  $3

# Shortcut to the files and binaries
ROOT=$PWD
PDB_FILEPATH=$ROOT/$1
DDPT_BIN=$ROOT/durham-ddpt-code/bin
CUTOFF=$2
RESIDUE_NUM=$3

# Extract PDB filename and ID name
PDB_FILENAME=$(basename "$PDB_FILEPATH" | sed 's/\(.*\)\.pdb$/\1/')
echo "PDB filename:"    $PDB_FILENAME
# PDB file path must be in a format '.*\/(....)_.*\.pdb$'
PDB_ID=$(echo "$PDB_FILENAME" | sed 's/.*\.\([[:digit:]]*\)$/\1/')
echo "PDB ID:"          $PDB_ID

# Pad cut-off and residued sequence number
printf -v CUTOFF_PAD "%04.1f" $CUTOFF
printf -v RESIDUE_NUM_PAD "%04d" $RESIDUE_NUM

# Create working directory
WORK_DIR=$ROOT/working-$PDB_FILENAME/cutoff-$CUTOFF_PAD/res-$RESIDUE_NUM_PAD
mkdir -p $WORK_DIR

# Create results directory and output files
RESULTS_DIR=$ROOT/results-$PDB_ID/cutoff-$CUTOFF_PAD
mkdir -p $RESULTS_DIR

ENERGY_FILE=$RESULTS_DIR/${PDB_FILENAME}.${RESIDUE_NUM_PAD}.1point.energy
echo "$RESIDUE_NUM" > $ENERGY_FILE

# Create the working directory
echo -n "Moving to working directory: "
pushd $WORK_DIR

# for SPRING_STRENGTH in 1.00
# for SPRING_STRENGTH in 0.25 0.30 0.35 0.40 0.45 0.50 0.58 0.67 0.75 0.88 1.00 1.25 1.50 1.75 2.00 2.25 2.50 2.75 3.00 3.25 3.50 3.75 4.00
for SPRING_STRENGTH in 0.25 0.313 0.375 0.438 0.5 0.563 0.625 0.688 0.75 0.813 0.875 0.938 1.00 1.25 1.50 1.75 2.00 2.25 2.50 2.75 3.00 3.25 3.50 3.75 4.00
do
    echo "Custom spring-constant:" $SPRING_STRENGTH

    echo "Writing: res.force"
    printf " %4s %1s %4s %1s %8.3f\n" $RESIDUE_NUM \* \* $CHAIN_ID $SPRING_STRENGTH > res.force

    echo "Running: GENENMM"
    $DDPT_BIN/GENENMM -pdb $PDB_FILEPATH -c $CUTOFF -ca -het -dna -lig1 -fcust res.force 

    echo "Running: DIAGSTD"
    $DDPT_BIN/DIAGSTD

    echo "Running: FREQEN for the first non-trivial 100 modes"
    $DDPT_BIN/FREQEN -s 7 -e 106

    # Append SPRING_STRENGTH label to the top of results
    echo "#$SPRING_STRENGTH" >> $ENERGY_FILE
    # Append G/kT column to results
    awk 'NR>1 {print $3}' mode.energy >> $ENERGY_FILE

    # Clean up
    rm -r $WORK_DIR/*
    echo
done

# Tidy up
echo -n "Moving out of working directory: "
pushd $ROOT
rm -rf $WORK_DIR
echo
echo "1-point scan complete."
