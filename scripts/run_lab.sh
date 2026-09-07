#!/usr/bin/env bash
# Run a lab node: scripts/run_lab.sh <package> <executable> [ros-args...]
# e.g. scripts/run_lab.sh safety_node safety_node.py
source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"
[[ $# -ge 2 ]] || { echo "usage: $0 <package> <executable> [args]"; exit 1; }
sim_up
in_sim -it "ros2 run $*"
