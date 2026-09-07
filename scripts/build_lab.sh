#!/usr/bin/env bash
# colcon build the lab workspace inside the container.
#   scripts/build_lab.sh                 # everything under labs/ws/src
#   scripts/build_lab.sh safety_node     # one package (and its deps)
source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"
sim_up
if [[ $# -gt 0 ]]; then sel="--packages-up-to $*"; else sel=""; fi
in_sim "cd /labs_ws && rosdep install -i --from-paths src --rosdistro jazzy -y -q >/dev/null 2>&1 || true
        colcon build --symlink-install $sel"
"$ROOT/scripts/fix_perms.sh"
