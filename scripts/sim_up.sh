#!/usr/bin/env bash
# Start the simulator container. With --build, (re)build the images first:
# the upstream simulator image ("base") and the lab layer on top ("sim").
source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"
if [[ "${1:-}" == "--build" ]]; then
  shift
  "${COMPOSE[@]}" --profile build build base
  "${COMPOSE[@]}" build sim
fi
"${COMPOSE[@]}" up -d "$@"
