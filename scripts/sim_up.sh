#!/usr/bin/env bash
# Start the simulator container.
#   --build   (re)build the images first: the upstream simulator image ("base")
#             and the lab layer on top ("sim")
#   --gpu     pass the RTX through (sim/docker-compose.gpu.yml override)
#   --cpu     no NVIDIA device; Mesa on the Intel iGPU
# Default is auto: gpu when the host NVIDIA stack is healthy, else cpu.
# Switching mode on a running container recreates it (compose sees the change).
BUILD=0
ARGS=()
for a in "$@"; do
  case "$a" in
    --build) BUILD=1 ;;
    --gpu)   export SIM_MODE=gpu ;;
    --cpu)   export SIM_MODE=cpu ;;
    *)       ARGS+=("$a") ;;
  esac
done
source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"
if [[ "$BUILD" == 1 ]]; then
  "${COMPOSE[@]}" --profile build build base
  "${COMPOSE[@]}" build sim
fi
echo "starting $SERVICE container ($MODE mode)" >&2
"${COMPOSE[@]}" up -d "${ARGS[@]}"
