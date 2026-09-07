# RoboRacer course workspace

Working through the RoboRacer (formerly F1TENTH) autonomous racing labs in
simulation. Everything ROS 2 runs in a Docker container (ROS 2 Jazzy); the host
stays on its own ROS 2 Humble.

## First time
```bash
git submodule update --init
scripts/sim_up.sh --build        # builds the image (~10 min), starts the container
```

## Every session
```bash
scripts/launch_sim.sh            # terminal 1: physics, LiDAR, odom, map, tf
scripts/rviz.sh                  # terminal 2: RViz on the host display
scripts/teleop.sh                # optional: drive with the keyboard
scripts/topics.sh                # health check: topic list + /scan rate
```
Foxglove alternative to RViz: open
<https://app.foxglove.dev/?ds=foxglove-websocket&ds.url=ws://localhost:8765>
and import `sim/f1tenth_gym_ros/config/foxglove/gym_bridge_foxglove.json`.

## Working on a lab
```bash
scripts/build_lab.sh [package]              # colcon build in the container
scripts/run_lab.sh <package> <executable>   # e.g. run_lab.sh safety_node safety_node.py
scripts/launch_lab.sh <package> <launch>    # e.g. launch_lab.sh lab1_pkg lab1_launch.py
scripts/test_lab.sh [package]
scripts/shell.sh                            # bash inside the container, /labs_ws
```
Edit code on the host in `labs/ws/src/<lab>/`; the container sees it live.

## Layout
```
CLAUDE.md          how Claude should tutor here, environment facts, progress
sim/               simulator submodule + docker-compose.yml
labs/ws/src/       one dir per lab, seeded from the official templates
notes/             one markdown per lab (copy notes/lab_template.md)
scripts/           the commands above
```

## Links
- Course: <https://roboracer.ai/learn>
- Course kit and lab index: <https://f1tenth-coursekit.readthedocs.io/en/latest/assignments/labs/index.html>
- Simulator: <https://github.com/f1tenth/f1tenth_gym_ros> (branch `dev-jazzy`)
- Lab templates: `https://github.com/f1tenth/f1tenth_lab{1..8}_template`
