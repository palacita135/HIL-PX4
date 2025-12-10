#!/usr/bin/env bash
set -euo pipefail

# Paths (adjust if you installed elsewhere)
PX4_DIR="$HOME/PX4-Autopilot"
AIRSIM_DIR="$HOME/AirSim/Blocks/LinuxBlocks1.8.1/LinuxNoEditor"
QGC_PATH="$HOME/qgc/QGroundControl.AppImage"

# Function to check if OpenGL works
check_opengl() {
    glxinfo >/dev/null 2>&1 || return 1
    glxinfo | grep "OpenGL version" >/dev/null 2>&1 || return 1
    return 0
}

# Decide if we can run GUI or fallback to nullrhi
if check_opengl; then
    echo "OpenGL detected. Launching AirSim with GUI..."
    AIRSIM_CMD="./Blocks.sh -opengl4"
else
    echo "OpenGL not detected. Falling back to headless AirSim..."
    AIRSIM_CMD="./Blocks.sh -nullrhi"
fi

# Launch PX4 SITL
gnome-terminal -- bash -ic "cd $PX4_DIR && make px4_sitl none; exec bash" &
sleep 6  # wait for PX4 to initialize

# Launch AirSim
gnome-terminal -- bash -ic "cd $AIRSIM_DIR && export RHI=OpenGL SDL_VIDEODRIVER=x11 && $AIRSIM_CMD; exec bash" &
sleep 4  # allow AirSim to connect

# Launch QGroundControl
gnome-terminal -- bash -ic "$QGC_PATH; exec bash" &

echo "Launched PX4, AirSim, and QGC. Check windows/logs for connectivity."
