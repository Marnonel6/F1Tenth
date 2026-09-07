#!/usr/bin/env bash
# Shared helpers for the RoboRacer workspace scripts. Source, don't run.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
COMPOSE=(docker compose -f "$ROOT/sim/docker-compose.yml")
SERVICE=sim

# Bring the sim container up (builds the image on first use).
sim_up() {
  if ! "${COMPOSE[@]}" ps --status running --services 2>/dev/null | grep -qx "$SERVICE"; then
    "${COMPOSE[@]}" up -d
  fi
}

# Run a command inside the container with ROS 2, the sim workspace and the
# lab workspace (if built) sourced. Usage: in_sim [-it] "<command>"
in_sim() {
  local flags=()
  if [[ "${1:-}" == "-it" ]]; then flags=(-it); shift; fi
  "${COMPOSE[@]}" exec "${flags[@]}" "$SERVICE" bash -c "
    source /opt/ros/jazzy/setup.bash
    source /sim_ws/install/setup.bash
    [ -f /labs_ws/install/setup.bash ] && source /labs_ws/install/setup.bash
    $*"
}
