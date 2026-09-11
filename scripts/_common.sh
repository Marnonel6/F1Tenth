#!/usr/bin/env bash
# Shared helpers for the RoboRacer workspace scripts. Source, don't run.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SERVICE=sim

# Container flavour. SIM_MODE=gpu|cpu|auto (default auto). auto picks gpu only
# when the host NVIDIA stack is healthy: nvidia-smi works (no driver/library
# mismatch from a pending reboot) and the persistenced socket that the CDI
# spec bind-mounts exists. Otherwise cpu: Mesa on the Intel iGPU via /dev/dri.
sim_mode() {
  case "${SIM_MODE:-auto}" in
    gpu|cpu) echo "$SIM_MODE" ;;
    *)
      if [[ -S /run/nvidia-persistenced/socket ]] && nvidia-smi -L >/dev/null 2>&1; then
        echo gpu
      else
        echo cpu
      fi ;;
  esac
}
MODE="$(sim_mode)"
COMPOSE=(docker compose -f "$ROOT/sim/docker-compose.yml")
if [[ "$MODE" == gpu ]]; then
  COMPOSE+=(-f "$ROOT/sim/docker-compose.gpu.yml")
fi

# Bring the sim container up (builds the image on first use).
sim_up() {
  if ! "${COMPOSE[@]}" ps --status running --services 2>/dev/null | grep -qx "$SERVICE"; then
    echo "starting $SERVICE container ($MODE mode)" >&2
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
