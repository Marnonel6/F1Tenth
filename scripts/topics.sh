#!/usr/bin/env bash
# Quick health check: list topics and measure /scan and /ego_racecar/odom rates.
source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"
sim_up
in_sim "ros2 topic list
        for t in /scan /ego_racecar/odom; do
          echo; echo \"\$t:\"
          timeout 6 ros2 topic hz \$t --window 20 2>&1 | grep -E 'average rate|no new messages' | tail -1
        done"
