#!/usr/bin/env bash
# Launch a lab launch file: scripts/launch_lab.sh <package> <launch_file> [args...]
source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"
[[ $# -ge 2 ]] || { echo "usage: $0 <package> <launch_file> [args]"; exit 1; }
sim_up
in_sim -it "ros2 launch $*"
