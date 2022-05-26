#!/bin/bash
# Generates ENM from PDB coordinates file, diagonalizes 
# the Hessian matrix, extracts eigenvalues and computes
# B-factor correlation.
# 
# DDPT must be installed and added to `PATH`

if [ "$#" -ne 4 ]; then
    echo "Usage: $0 <work-dir> <output-dir> <pdb-filepath> <GENENMM-flags>"
    echo "Example: $0 "pdb/processed/1.pdb" "tmp/-ca-het-c8.0" "data/raw/-ca-het-c8.0" "-ca -het -c 8.0""
    exit 1
fi

echo "Working dir:"     $1
echo "Output dir:"      $2
echo "PDB filepath:"    $3
echo "GENENMM flags:"   $4

# Shortcut to the files and binaries
WORK_DIR=$1
OUTPUT_DIR=$2
PDB_PATH=$3
GENENMM_FLAGS=$4

LOG_FILE="ddpt.log"

# PDB filepath must be in a format ${FORM_IDX}.pdb
FORM_IDX=$(basename "${PDB_PATH}")
FORM_IDX="${FORM_IDX%%.*}"
echo "Complex form index: ${FORM_IDX}" >> ${LOG_FILE}        

mkdir -p ${OUTPUT_DIR} ${WORK_DIR} 

cp ${PDB_PATH} ${WORK_DIR}/ddpt_input_struct.pdb

echo -n "Moving to working directory:"
pushd ${WORK_DIR}

echo ${GENENMM_FLAGS} >> ${LOG_FILE}

echo "Running: GENENMM"
GENENMM -pdb ddpt_input_struct.pdb $GENENMM_FLAGS >> ${LOG_FILE}
echo "Running: DIAGSTD"
DIAGSTD -i matrix.sdijf >> ${LOG_FILE}
echo "Running: FREQEN"
FREQEN -i matrix.eigenfacs -s 7 -e 9999 >> ${LOG_FILE}

# B-factors are not required for cooperativity calcualtins
# echo "Running: RMSCOL"
# if echo $GENENMM_FLAGS | grep -q '-res.*-mass\|-mass.*-res'
# then
#     RMSCOL -i matrix.eigenfacs -pdb CAonly.pdb -s 7 -e 9999 -res -mass >> ${LOG_FILE}

# elif echo $GENENMM_FLAGS | grep -q '-mass'
# then
#     RMSCOL -i matrix.eigenfacs -pdb CAonly.pdb -s 7 -e 9999 -mass >> ${LOG_FILE}

# elif echo $GENENMM_FLAGS | grep -q '-res'
# then
#     RMSCOL -i matrix.eigenfacs -pdb CAonly.pdb -s 7 -e 9999 -res >> ${LOG_FILE}
    
# else
#     RMSCOL -i matrix.eigenfacs -pdb CAonly.pdb -s 7 -e 9999 >> ${LOG_FILE}
# fi

popd

# cp  ${WORK_DIR}/* -t ${OUTPUT_DIR}

# rm -rf ${WORK_DIR}

echo "ENM was built successfully!"
