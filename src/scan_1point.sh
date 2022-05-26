#!/bin/bash
# Runs elastic network model (ENM) 1-point mutational scan 
# for passed residue number
# Generates ENM from PDB coordinates file, diagonalizes 
# the Hessian matrix and extracts eigenvalues 
# which are saved
# 
# 
# DDPT must be installed and added to `PATH`
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <pdb-filepath> <cutoff> <residue-number>"
    echo "Example: $0 pdb/1.pdb 8.0 145"
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
CUTOFF=$2
RESIDUE_NUM=$3

# Allow for deleting everything except certain extension
shopt -s extglob

# Extract PDB file form index
FORM_IDX=$(basename "${PDB_PATH}")
FORM_IDX="${FORM_IDX%%.*}"

# Pad cut-off and residued sequence number
printf -v CUTOFF_PAD "%05.2f" $CUTOFF
printf -v RESIDUE_NUM_PAD "%04d" $RESIDUE_NUM

# Create working directory
WORK_DIR=$ROOT/working-$PDB_FILENAME/c${CUTOFF_PAD}/res${RESIDUE_NUM_PAD}
mkdir -p $WORK_DIR

# Create results directory and output files
RESULTS_DIR=$ROOT/data
mkdir -p $RESULTS_DIR

EIGVALS_FILE=$RESULTS_DIR/${FORM_IDX}.res${RESIDUE_NUM_PAD}.csv

GENENMM_FLAGS="-c 0.0 -f 1 -ca -het -mass -res -ccust cutoff.ddpt -spcust spring.ddpt -fcust resforce.ddpt"

mkdir -p ${WORK_DIR}

# Create the working directory
echo -n "Moving to working directory: "
pushd $WORK_DIR

# Copy auxilary files, if any are present,
# for -mass -ca -res, -ccust, -spcust and -fcust flags. 
cp -f misc/*.ddpt -t ${WORK_DIR} 2> /dev/null
cp ${PDB_PATH} ${WORK_DIR}/origin_struct.pdb

echo "Writing DDPT cfile file:"
printf '%4s %7.3f\n' " CA " "${CUTOFF}" > cutoff.ddpt
printf '%4s %7.3f\n' " LG " "0.0" >> cutoff.ddpt

# Generate an EN for single-bead mass-weigthed ligands
echo "Creating EN PDB file:"
GENENMM -pdb origin_struct.pdb -res -mass -ca -het -lig1
sed -i 's/\(HETATM.\{6\}\) CA /\1 LG /' CAonly.pdb
mv CAonly.pdb en_struct.pdb

# Come back to the root
popd

# for SPRING_STRENGTH in 1.00
# Scan doesn't have ${SPRING_STRENGTH} == 1.00
# this value correspond to wild-type ENM and is the same for all scans
for SPRING_STRENGTH in 0.25 0.313 0.375 0.438 0.5 0.563 0.625 0.688 0.75 0.813 0.875 0.938 1.25 1.50 1.75 2.00 2.25 2.50 2.75 3.00 3.25 3.50 3.75 4.00
do
    pushd $WORK_DIR
    echo "Custom spring-constant:" $SPRING_STRENGTH

    echo "Writing DDPT resforce file:"
    rm -f $WORK_DIR/resforce.ddpt
    # Asteriks "*" denote wild-card residue number and chain ID
    for CHAIN_ID in A B 
    do
        printf " %4s %1s %4s %1s %8.3f\n" $RESIDUE_NUM $CHAIN_ID \* \* $SPRING_STRENGTH >> $WORK_DIR/resforce.ddpt
    done

    # Append SPRING_STRENGTH label to the top of results
    echo "#$SPRING_STRENGTH" >> ${EIGVALS_FILE}

    bash src/run_enm.sh "${WORK_DIR}" \
        "${OUTPUT_DIR}" \
        "${WORK_DIR}/en_struct.pdb" \
        "${GENENMM_FLAGS}"

    # Extract eigenvalues
    grep -v "^#" ${WORK_DIR}/mode.frequencies >> ${EIGVALS_FILE}

    # Clean up but leave DDPT aux files and PDB files
    rm -rf $WORK_DIR/!(*.ddpt|*.pdb) 
    echo
done

echo -n "Moving out of working directory: "
pushd $ROOT

# Tidy up
rm -rf $WORK_DIR

echo
echo "1-point ENM scan complete."
