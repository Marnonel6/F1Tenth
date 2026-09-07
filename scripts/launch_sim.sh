#!/usr/bin/env bash
# Launch the gym bridge (physics + LiDAR + odom + map + tf) in the foreground.
# Ctrl-C stops it; the container keeps running.
#
#   scripts/launch_sim.sh                       # levine map, 1 car
#   scripts/launch_sim.sh num_agents:=2         # ego + 1 opponent
#   scripts/launch_sim.sh map_path:=Spielberg   # any gym_bridge_launch.py arg
#
# Visualise with scripts/rviz.sh, or Foxglove at
# https://app.foxglove.dev/?ds=foxglove-websocket&ds.url=ws://localhost:8765
source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"
sim_up
in_sim -it "ros2 launch f1tenth_gym_ros gym_bridge_launch.py open_foxglove:=false $*"
