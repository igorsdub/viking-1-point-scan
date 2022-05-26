#!/bin/bash
# Concatinate 1-point mutational scan results into 
# single file multi-column file 

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <form-idx>"
    echo "Example: $0 1"
    exit 1
fi

FORM_IDX=$1

paste -d "," $FORM_IDX.res????.csv > $FORM_IDX.1point.csv
