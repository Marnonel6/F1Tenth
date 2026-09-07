#!/usr/bin/env bash
# Interactive bash inside the sim container, everything sourced, cwd /labs_ws.
source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"
sim_up
in_sim -it "cd /labs_ws && exec bash"
