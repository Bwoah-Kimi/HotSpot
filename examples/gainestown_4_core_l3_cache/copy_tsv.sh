#!/usr/bin/env bash

# Script Name: run.sh
# Author: Zhantong Zhu [Peking University]
# Description: Copy the temp_trace.tsv files from the specified source directory to the destination directory.
# Usage: ./copy_tsv.sh <source_directory> <destination_directory>


if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <source_directory> <destination_directory>"
    exit 1
fi

SOURCE_DIR=$1
DEST_DIR=$2

# Create the destination directory if it doesn't exist
mkdir -p $DEST_DIR

# Loop through each subdirectory in the source directory
for SUBDIR in $SOURCE_DIR/*; do
    if [ -d "$SUBDIR" ]; then
        BASENAME=$(basename $SUBDIR)
        BASENAME=${BASENAME#outputs_}
        BASENAME=${BASENAME//power_trace/thermal_trace}
        TSV_FILE="$SUBDIR/temp_trace.tsv"
        if [ -f "$TSV_FILE" ]; then
            cp "$TSV_FILE" "$DEST_DIR/${BASENAME}.tsv"
            echo "Copied $TSV_FILE to $DEST_DIR/${BASENAME}.tsv"
        else
            echo "No temp_trace.tsv found in $SUBDIR"
        fi
    fi
done