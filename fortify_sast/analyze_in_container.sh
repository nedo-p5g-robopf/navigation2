#!/bin/bash

# This script runs in a container to scan Navigation2 using Fortify.

set -e

cd /opt/overlay_ws

# Build and load environment variables
. $UNDERLAY_WS/install/setup.sh
colcon build \
    --symlink-install \
    --mixin $OVERLAY_MIXINS \
    --parallel-workers 1 \
    --cmake-args -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
. $OVERLAY_WS/install/setup.sh

PATH=$PATH:/opt/Fortify/OpenText_SAST_Fortify_25.4.0/bin

# Initialize
sourceanalyzer -b navigation2_sast -clean

# Specify source codes written in Python
sourceanalyzer -b navigation2_sast -python-version 3 -python-path $PYTHONPATH \
    $(find ./src/navigation2 -name "*.py")
# Specify source codes written in C++
sourceanalyzer -b navigation2_sast build/compile_commands.json

# Analyze
echo "Start analysis"
sourceanalyzer -b navigation2_sast -scan -Xmx12G -D com.fortify.sca.rules.IsLibrary=true -sc classic -f /opt/results/navigation2_sast_result.fpr
echo "Finished analysis"
