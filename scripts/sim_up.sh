#!/usr/bin/env bash
# Start (and if needed build) the simulator container. Does not launch the sim.
source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"
"${COMPOSE[@]}" up -d "$@"
