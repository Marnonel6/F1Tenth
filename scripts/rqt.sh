#!/usr/bin/env bash
# Open rqt (inside the container) on the host X display.
# Usage: scripts/rqt.sh            -> rqt_graph
#        scripts/rqt.sh plot       -> rqt_plot   (any rqt_<name>)
#        scripts/rqt.sh gui        -> full rqt with plugin menu
source "$(dirname "${BASH_SOURCE[0]}")/_common.sh"
xhost +local:docker >/dev/null
sim_up
tool="${1:-graph}"; shift || true
in_sim -it "rqt_${tool} $*"
