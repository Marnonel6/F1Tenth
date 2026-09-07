#!/usr/bin/env bash
# Quick health check: list topics and measure /scan and /ego_racecar/odom rates.
source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"
sim_up
in_sim "ros2 topic list && echo && timeout 6 ros2 topic hz /scan --window 20 2>&1 | tail -3; echo; timeout 6 ros2 topic hz /ego_racecar/odom --window 20 2>&1 | tail -3"
