#!/usr/bin/env bash

# Remove results from previous simulatiosn
rm -f temp.init
rm -f outputs/*
# Create outputs directory if it doesn't exist
mkdir outputs

../../bin/hotspot \
    -c example.config \
    -f cim_tile.flp \
    -p ptrace \
    -materials_file example.materials \
    -model_type grid \
    -steady_file outputs/temp.steady \
    -grid_steady_file outputs/temp.grid.steady \
    -grid_rows 64 \
    -grid_cols 64 


cp outputs/temp.steady temp.init

../../bin/hotspot \
    -c example.config \
    -init_file temp.init \
    -f cim_tile.flp \
    -p ptrace \
    -materials_file example.materials \
    -model_type grid \
    -o outputs/block.ttrace \
    -grid_transient_file outputs/grid.ttrace \
    -grid_rows 64 \
    -grid_cols 64 \

../../scripts/split_grid_steady.py outputs/temp.grid.steady 4 64 64
../../scripts/grid_thermal_map.pl cim_tile.flp outputs/temp_layer0.grid.steady > outputs/layer0.svg
../../scripts/grid_thermal_map.py cim_tile.flp outputs/temp_layer0.grid.steady outputs/layer0.png

