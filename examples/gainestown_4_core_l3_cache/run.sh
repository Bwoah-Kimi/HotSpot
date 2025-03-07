#!/usr/bin/env bash

# Script Name: run.sh
# Author: Zhantong Zhu [Peking University]
# Description: This script runs the HotSpot thermal simulator with the specified power trace file.
# Usage: ./run.sh <power_trace_file> <index>
# Arguments:
#   <power_trace_file> - The power trace file to be used by HotSpot.
#   <index> - An index to distinguish different runs.

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <power_trace_file> <index>"
    exit 1
fi

if [ -z "$TRACE_OUTPUT_DIR" ] || [ -z "$HOTSPOT_RUN_DIR" ]; then
    echo "Environment variables TRACE_OUTPUT_DIR and HOTSPOT_RUN_DIR must be set."
    exit 1
fi

echo "Running HotSpot with power trace file: $1, index: $2, trace_output_dir: $TRACE_OUTPUT_DIR"

POWER_TRACE_FILE=$1

INDEX=$2
# INDEX=${INDEX%_power_trace}

OUTPUT_DIR="${HOTSPOT_RUN_DIR}/outputs_${INDEX}"
INIT_TEMP_FILE="${HOTSPOT_RUN_DIR}/init_temp_${INDEX}"

rm -f $INIT_TEMP_FILE
rm -rf $OUTPUT_DIR

mkdir $OUTPUT_DIR/
mkdir -p $TRACE_OUTPUT_DIR/

${HOTSPOT_RUN_DIR}/../../bin/hotspot \
    -c "${HOTSPOT_RUN_DIR}/gainestown_4_core_l3_cache.config" \
    -f "${HOTSPOT_RUN_DIR}/gainestown_4_core_l3_cache.flp" \
    -p $POWER_TRACE_FILE \
    -sampling_intvl 0.001 \
    -steady_file $OUTPUT_DIR/steady_temp \
    -o $OUTPUT_DIR/temp_trace.tsv

cp $OUTPUT_DIR/steady_temp $INIT_TEMP_FILE

${HOTSPOT_RUN_DIR}/../../bin/hotspot \
    -c "${HOTSPOT_RUN_DIR}/gainestown_4_core_l3_cache.config" \
    -f "${HOTSPOT_RUN_DIR}/gainestown_4_core_l3_cache.flp" \
    -p $POWER_TRACE_FILE \
    -init_file $INIT_TEMP_FILE \
    -sampling_intvl 0.001 \
    -steady_file $OUTPUT_DIR/steady_temp \
    -o $OUTPUT_DIR/temp_trace.tsv

cp $OUTPUT_DIR/temp_trace.tsv $TRACE_OUTPUT_DIR/${INDEX}_thermal_trace.tsv
echo "Copied $OUTPUT_DIR/temp_trace.tsv to $TRACE_OUTPUT_DIR/${INDEX}_thermal_trace.tsv"