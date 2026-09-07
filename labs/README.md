# Lab workspace

One shared colcon workspace (`ws/`) with one directory per lab under `src/`.
Each lab directory is the official template with git history stripped
(see `TEMPLATES.md`); the ROS 2 package lives inside it.

| Dir | Package | Lab |
|---|---|---|
| `lab1_intro_ros2/` | `lab1_pkg` (you create it) | Intro to ROS 2: talker/relay, launch file |
| `lab2_aeb/` | `safety_node` | Automatic Emergency Braking (time-to-collision) |
| `lab3_wall_follow/` | `wall_follow` | PID wall following |
| `lab4_gap_follow/` | `gap_follow` | Follow the Gap (reactive) |
| `lab5_slam_pure_pursuit/` | `pure_pursuit` | SLAM + pure pursuit on a recorded raceline |
| `lab6_motion_planning/` | `lab7_pkg` (RRT, upstream naming) | Sampling-based planning |
| `lab7_vision/` | none (calibration images) | Camera calibration, detection, lane |
| `lab8_mpc/` | `mpc` | Model Predictive Control |

Lab 9 (Robot Ethics) has no code; notes only.

Why one workspace, not one per lab: a single `colcon build` and one
`install/setup.bash` to source, packages can reuse each other (lab 5 wants lab 3/4's
driving, lab 8 wants lab 5's raceline), and the sim container mounts one path.
The cost is that a broken package blocks the build; use
`scripts/build_lab.sh <package>` to build one at a time.

The workspace is mounted at `/labs_ws` in the sim container. Build with
`scripts/build_lab.sh`, run with `scripts/run_lab.sh <pkg> <exe>`. `build/`,
`install/`, `log/` are git-ignored and root-owned until `scripts/fix_perms.sh` runs
(build_lab does that for you).
