#!/usr/bin/env bash
# The container runs as root, so builds leave root-owned files in labs/ws and
# sim/f1tenth_gym_ros. Reclaim them for the host user.
source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"
in_sim "chown -R $(id -u):$(id -g) /labs_ws /sim_ws/src/f1tenth_gym_ros" 2>/dev/null || true
