#!/bin/bash

set -e

cd /opt/overlay_ws

export PATH="/opt/cov-analysis-linux64-2026.3.2/bin:$PATH"
rm -rf ./build/ ./install/ ./log/ ./cov-int/*
cov-configure --gcc

export CXX=g++
export MAKEFLAGS="-j3"

cov-build --dir cov-int \
    colcon build \
    --parallel-workers 1

cov-analyze --dir cov-int

cov-format-errors \
    --dir cov-int \
    --json-output-v10 /opt/results/coverity.json
