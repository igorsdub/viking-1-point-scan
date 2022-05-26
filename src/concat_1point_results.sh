#!/bin/bash
# Concatinate 1-point mutational scan results into 
# single file multi-column file 

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <pdb-id> <form-idx>"
    echo "Example: $0 1c3b 1"
    exit 1
fi

PDB_ID=$1
FORM_IDX=$2

paste -d "," $PDB_ID.$FORM_IDX.*.1point.energy > $PDB_ID.$FORM_IDX.1point.energy.csv
