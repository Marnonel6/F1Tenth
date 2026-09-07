# RoboRacer learning workspace

Marno (director of product & engineering for an orchard-autonomy program:
autonomous tractors, ROS 2 Humble, Ubuntu, Docker; MSc robotics) is working
through the RoboRacer / F1TENTH autonomous racing course in simulation to get
hands-on with a full autonomy stack again. Goal: learn, not ship. Long-term:
RoboRacer labs in sim, then a small Gazebo orchard-row sandbox reusing the same
nodes, possibly a physical car later.

## How to behave here

- I am learning. Do not implement lab solutions unless I explicitly say
  "implement this". Default modes: explain, ask me questions, review my code,
  help me debug. If I'm stuck, give a hint before giving an answer.
- When you review my code, say what's wrong and why, point me at the concept
  (and the lecture module if you know it), and let me fix it.
- After each lab, ask me two or three questions that check I understood the
  concept, and ask how the same idea applies to a tractor following a tree row.
- You may freely write boilerplate that isn't the point of the lab: package.xml,
  CMakeLists / setup.py, launch files, Dockerfiles, scripts, RViz configs,
  README notes.
- Prefer Python for the labs unless I say otherwise.
- Everything ROS 2 runs inside the Docker container. Never install ROS, apt or
  pip packages on the host. The host runs ROS 2 Humble for my day job.
- Keep the Progress section at the bottom of this file current. I start each lab
  in a fresh session and expect you to resume from it.
- Global rules also apply: task list for multi-step work, one commit per task.
- Commit messages: plain, no Co-Authored-By or Claude-Session trailers, no AI
  attribution anywhere.

## Environment (verified 2026-09-07)

| Item | Value |
|---|---|
| Host | Ubuntu 22.04.5, ROS 2 Humble (untouched), X11 on `DISPLAY=:1` |
| Container | `roboracer_sim`, image `roboracer_sim:jazzy` = upstream image `roboracer_base:jazzy` + `sim/Dockerfile` (osqp, osqp-eigen, cvxpy, scipy, numba for the lab templates). ROS 2 **Jazzy**, Ubuntu 24.04, Python 3.12 |
| Docker | 29.5, Compose v5.1, host networking, `ipc: host`, `ROS_DOMAIN_ID=1` in the container |
| GPU | RTX 3070 Laptop, passed through via CDI `nvidia.com/gpu=all` (no nvidia runtime registration needed). Host X runs on the Intel iGPU; the RTX is a PRIME offload provider, so compose sets `__NV_PRIME_RENDER_OFFLOAD=1` and `__GLX_VENDOR_LIBRARY_NAME=nvidia` and also passes `/dev/dri` (Mesa/Intel fallback if those are removed). Physics is CPU JAX regardless. |
| Display | RViz over X11 (`scripts/rviz.sh`, does `xhost +local:docker`). Foxglove in browser at ws://localhost:8765 as alternative. Port 8080 is taken on the host, so no noVNC. |
| Simulator | `f1tenth_gym_ros` branch `dev-jazzy` (submodule, `sim/f1tenth_gym_ros`), gym `f1tenth_gym` branch `dev-jax` installed in image at `/sim_ws/f1tenth_gym`, CPU JAX |
| Mounts | `sim/f1tenth_gym_ros` -> `/sim_ws/src/f1tenth_gym_ros`, `labs/ws` -> `/labs_ws` |
| Container user | root; `scripts/fix_perms.sh` reclaims files (build_lab runs it) |
| Host <-> container ROS | Isolated on purpose: container runs `ROS_DOMAIN_ID=1`, host Humble stays on 0. Two reasons. (1) With host networking both `ros2` CLIs use the daemon port `11511 + domain`, so on the same domain the container CLI talks to the host Humble daemon and `ros2 node list` comes back empty. (2) Humble's Fast DDS 2.6 cannot parse Jazzy's Fast DDS 2.14 discovery data (`sequence size exceeds remaining buffer`), so host tools never see the sim anyway. Run every ROS tool (rqt, ros2 topic, rviz2) inside the container. |

Course distro: the lab templates and simulator target ROS 2 Jazzy as of Sept 2026.

## Commands

All scripts start the container if needed. Run from the repo root.

| Task | Command |
|---|---|
| Build image / start container | `scripts/sim_up.sh --build` (first time), `scripts/sim_up.sh` |
| Launch sim (foreground, Ctrl-C stops) | `scripts/launch_sim.sh [num_agents:=2] [map_path:=Spielberg] [config:=my.yaml]` |
| RViz | `scripts/rviz.sh` |
| rqt | `scripts/rqt.sh` (graph), `scripts/rqt.sh plot`, `scripts/rqt.sh console`, `scripts/rqt.sh gui` |
| Keyboard teleop | `scripts/teleop.sh` (i/u/o forward, ,/m/. back, k stop) |
| Health check | `scripts/topics.sh` |
| Shell in container | `scripts/shell.sh` (cwd `/labs_ws`, everything sourced) |
| Build labs | `scripts/build_lab.sh [package]` |
| Run a node | `scripts/run_lab.sh <package> <executable> [--ros-args ...]` |
| Launch a lab | `scripts/launch_lab.sh <package> <launch_file> [args]` |
| Tests | `scripts/test_lab.sh [package]` |
| Stop container | `scripts/sim_down.sh` |

Inside the container, sourcing is: `/opt/ros/jazzy/setup.bash`,
`/sim_ws/install/setup.bash`, `/labs_ws/install/setup.bash`.
Sim config: `sim/f1tenth_gym_ros/config/sim.yaml` (map, num_agents, start poses,
LiDAR params). Rebuild the sim workspace after editing it:
`scripts/shell.sh` then `cd /sim_ws && colcon build --symlink-install`.

## Sim topics and frames

Single agent (default). Message types in parentheses.

| Topic | Dir | Type | Notes |
|---|---|---|---|
| `/scan` | sim -> you | `sensor_msgs/LaserScan` | 819 beams, -135..135 deg, 0.05..25 m, frame `ego_racecar/laser` |
| `/ego_racecar/odom` | sim -> you | `nav_msgs/Odometry` | pose of `base_link` (rear axle) in `map` |
| `/ego_racecar/collision` | sim -> you | `std_msgs/Bool` | instantaneous, not latched |
| `/ego_racecar/lap_count`, `/lap_time` | sim -> you | `Int32`, `Float32` | needs a map with a centerline (levine, Spielberg) |
| `/map` | sim -> you | `nav_msgs/OccupancyGrid` | from nav2 map_server |
| `/drive` | you -> sim | `ackermann_msgs/AckermannDriveStamped` | `drive.speed` m/s, `drive.steering_angle` rad |
| `/initialpose` | you -> sim | `PoseWithCovarianceStamped` | reset ego (RViz 2D Pose Estimate) |
| `/cmd_vel` | teleop -> sim | `geometry_msgs/Twist` | only when `kb_teleop: True` |
| `/clock` | sim -> all | `rosgraph_msgs/Clock` | only when `use_sim_time: True` |
| `/pause_sim` | you -> sim | `std_msgs/Bool` | pause / resume physics |

Measured 2026-09-07: `/scan` and odom both stream at roughly 240 Hz in the default
async mode (the sim steps on a timer, faster than a real 40 Hz Hokuyo/SICK). Do not
assume real-sensor rates in lab code; read `scan.header.stamp`.

Multi agent adds `/opp_scan[N]`, `/opp_drive[N]`, `/opp_racecar[N]/odom`,
`/ego_racecar/opp_odom[N]`, `/goal_pose[N]` (reset opponent N). First opponent
has no suffix, then 2, 3, ...

Frames: `map` -> `ego_racecar/base_link` -> `ego_racecar/laser` (laser is
0.275 m ahead of base_link). Opponents: `opp_racecar[N]/base_link`.
Default map `maps/levine`, ego start `(-12, 0, 0)`.

## Links

- Course: https://roboracer.ai/learn
- Lab index (course kit): https://f1tenth-coursekit.readthedocs.io/en/latest/assignments/labs/index.html
- Course kit home: https://f1tenth-coursekit.readthedocs.io/
- Simulator: https://github.com/f1tenth/f1tenth_gym_ros (branch `dev-jazzy`), README has topic details and FAQ
- Gym docs: https://f1tenth-gym.readthedocs.io/
- Lab templates: https://github.com/f1tenth/f1tenth_lab{1..8}_template (provenance in `labs/TEMPLATES.md`)
- Submission format reference: https://github.com/AhmadAmine998/roboracer-class-submission-template
- ROS 2 Jazzy tutorials: https://docs.ros.org/en/jazzy/Tutorials.html

## Progress

- Lab 1 (Intro to ROS 2) — skipped 2026-09-07. Marno already knows the
  material (talker/relay nodes, params, launch files, Docker). The package
  build/run workflow gets exercised at the start of Lab 2 instead.
- Lab 2 (Automatic Emergency Braking) — next, not started. Template:
  `labs/ws/src/lab2_aeb/safety_node/` (already builds). Concept: iTTC =
  r / max(-r_dot, 0) per beam, r_dot from v_x cos(theta_i) (odom
  `twist.twist.linear.x`) or from consecutive scans. Node subscribes `/scan` and
  `/ego_racecar/odom`, publishes `/drive` speed 0.0 when min iTTC < threshold;
  must handle inf/nan and avoid false positives in the Levine hallway. Test with
  `scripts/teleop.sh` (needs `kb_teleop: True` in sim.yaml, already the default)
  driving at a wall. Deliverables: working package, screencast, `SUBMISSION.md`.
- Open questions: none yet.
