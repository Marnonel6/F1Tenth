#!/usr/bin/env bash
# Run colcon tests for one or all lab packages and print results.
source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"
sim_up
if [[ $# -gt 0 ]]; then sel="--packages-select $*"; else sel=""; fi
in_sim "cd /labs_ws && colcon test $sel && colcon test-result --verbose"
