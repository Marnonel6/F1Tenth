#!/usr/bin/env bash
# Open RViz (inside the container) on the host X display with the sim layout.
source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"
xhost +local:docker >/dev/null
sim_up
in_sim -it "rviz2 -d /sim_ws/src/f1tenth_gym_ros/config/rviz/gym_bridge.rviz"
