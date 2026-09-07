# Lab layer on top of the upstream f1tenth_gym_ros image (built from the
# submodule, see docker-compose.yml service "base"). Adds what the lab
# templates need beyond the simulator itself.
ARG BASE_IMAGE=roboracer_base:jazzy
FROM ${BASE_IMAGE}

SHELL ["/bin/bash", "-c"]
ENV DEBIAN_FRONTEND=noninteractive

# Lab 8 (MPC) C++ template links OsqpEigen; neither osqp nor osqp-eigen ship
# as apt/rosdep packages, so build them from source.
RUN apt-get update && \
    apt-get install -y --no-install-recommends cmake build-essential libeigen3-dev && \
    rm -rf /var/lib/apt/lists/* && \
    git clone --depth 1 --branch v0.6.3 --recursive https://github.com/osqp/osqp.git /tmp/osqp && \
    cmake -S /tmp/osqp -B /tmp/osqp/build -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON && \
    cmake --build /tmp/osqp/build -j"$(nproc)" && cmake --install /tmp/osqp/build && \
    git clone --depth 1 --branch v0.8.1 https://github.com/robotology/osqp-eigen.git /tmp/osqp-eigen && \
    cmake -S /tmp/osqp-eigen -B /tmp/osqp-eigen/build -DCMAKE_BUILD_TYPE=Release && \
    cmake --build /tmp/osqp-eigen/build -j"$(nproc)" && cmake --install /tmp/osqp-eigen/build && \
    ldconfig && rm -rf /tmp/osqp /tmp/osqp-eigen

# Python deps used by the lab templates (numpy already comes with the gym):
# lab 8 mpc_node.py -> cvxpy, scipy; lab 6 rrt -> numba.
RUN pip3 install --no-cache-dir cvxpy scipy numba

# Lab workspace sourced in interactive shells when it exists
RUN echo '[ -f /labs_ws/install/setup.bash ] && source /labs_ws/install/setup.bash' >> /root/.bashrc

WORKDIR /labs_ws
ENTRYPOINT ["/bin/bash"]
