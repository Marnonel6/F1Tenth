#!/usr/bin/env bash
# Drive the ego car with the keyboard (i/u/o forward, ,/m/. back, k stop).
source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"
sim_up
in_sim -it "ros2 run teleop_twist_keyboard teleop_twist_keyboard"
