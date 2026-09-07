#!/usr/bin/env bash
# Stop and remove the simulator container. The image and your files stay.
source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"
"${COMPOSE[@]}" down
