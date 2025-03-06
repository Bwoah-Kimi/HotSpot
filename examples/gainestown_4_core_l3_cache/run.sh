#!/usr/bin/env bash

if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <power_trace_file> <index> <trace_output_dir>"
    exit 1
fi

echo "Running HotSpot with power trace file: $1, index: $2, trace_output_dir: $3"

RUN_DIR="/Users/zhantong/Workspace/Open-Source-Projects/HotSpot/examples/gainestown_4_core_l3_cache"

POWER_TRACE_FILE=$1
INDEX=$2
OUTPUT_DIR="${RUN_DIR}/outputs_${INDEX}"
INIT_TEMP_FILE="${RUN_DIR}/init_temp_${INDEX}"
TRACE_OUTPUT_DIR=$3

rm -f $INIT_TEMP_FILE
rm -rf $OUTPUT_DIR

mkdir $OUTPUT_DIR/
mkdir -p $TRACE_OUTPUT_DIR/

LOG_FILE="${RUN_DIR}/run.log"

{
    ${RUN_DIR}/../../bin/hotspot \
        -c "${RUN_DIR}/gainestown_4_core_l3_cache.config" \
        -f "${RUN_DIR}/gainestown_4_core_l3_cache.flp" \
        -p $POWER_TRACE_FILE \
        -sampling_intvl 0.001 \
        -steady_file $OUTPUT_DIR/steady_temp \
        -o $OUTPUT_DIR/temp_trace.tsv

    cp $OUTPUT_DIR/steady_temp $INIT_TEMP_FILE

    ${RUN_DIR}/../../bin/hotspot \
        -c "${RUN_DIR}/gainestown_4_core_l3_cache.config" \
        -f "${RUN_DIR}/gainestown_4_core_l3_cache.flp" \
        -p $POWER_TRACE_FILE \
        -init_file $INIT_TEMP_FILE \
        -sampling_intvl 0.001 \
        -steady_file $OUTPUT_DIR/steady_temp \
        -o $OUTPUT_DIR/temp_trace.tsv

    cp $OUTPUT_DIR/temp_trace.tsv $TRACE_OUTPUT_DIR/
} | tee -a $LOG_FILE