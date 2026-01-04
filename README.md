## PX4 + AirSim + QGroundControl — Ubuntu 22.04 install & HIL quickstart ##

A compact, copy-pasteable README to get PX4 SITL, AirSim (Blocks), and QGroundControl running on Ubuntu 22.04 and to run HIL (AirSim ⇄ PX4 ⇄ QGC). Includes exact commands, settings.json, troubleshooting tips, and a tiny launcher script. Tested approach: modern PX4 + prebuilt AirSim Blocks binary + QGC AppImage.

Quick summary: install PX4 deps, grab PX4 source, download prebuilt AirSim Blocks for Linux, download QGroundControl AppImage, configure AirSim settings.json, then start in the order PX4 → AirSim → QGC. If you like surprises, skip the order and enjoy reconnect spam.

# Important links (grab these first)
* PX4 dev install & ubuntu helper script: PX4 docs. (https://docs.px4.io/main/en/dev_setup/dev_env_linux_ubuntu?utm_source=chatgpt.com)
* AirSim releases (prebuilt Blocks and other env zips): GitHub releases. (https://github.com/microsoft/airsim/releases?utm_source=chatgpt.com)
* QGroundControl AppImage (Linux): QGC download instructions. (https://docs.qgroundcontrol.com/master/en/qgc-user-guide/getting_started/download_and_install.html?utm_source=chatgpt.com)
* AirSim precompiled instructions / binaries page. (https://microsoft.github.io/AirSim/use_precompiled/?utm_source=chatgpt.com)

# System requirements (recommended)
* Ubuntu 22.04 LTS (this guide targets 22.04).
* 8+ GB RAM (16 GB or more recommended).
* GPU strongly recommended for AirSim Blocks (integrated Intel may work but expect pain). If you have no GPU or weak GPU, use headless mode or run AirSim on a different machine.
* ~40 GB free disk (PX4 + AirSim + caches).

# 0 — Quick checklist (TL;DR)
* Install PX4 prerequisites (use PX4 ubuntu.sh). (https://github.com/PX4/PX4-Autopilot/blob/main/Tools/setup/ubuntu.sh?utm_source=chatgpt.com)
* Clone PX4 source.
* Download AirSim Blocks (LinuxNoEditor) from releases and unzip. (https://github.com/microsoft/airsim/releases?utm_source=chatgpt.com)
* Download QGroundControl AppImage and make executable. (https://docs.qgroundcontrol.com/master/en/qgc-user-guide/getting_started/download_and_install.html?utm_source=chatgpt.com)
* Place AirSim settings.json (below) in ~/.config/AirSim/ or the AirSim folder.
* Start PX4 (make px4_sitl none), then AirSim Blocks, then QGC.

# 1 — Install PX4 dependencies and clone repository
Open a terminal and run:
```bash
# recommended: run on a fresh Ubuntu 22.04 setup
sudo apt update && sudo apt upgrade -y

# optional: install git, cmake, python if missing
sudo apt install -y git python3 python3-pip

# clone PX4 (recursive to get submodules)
cd $HOME
git clone https://github.com/PX4/PX4-Autopilot.git --recursive
cd PX4-Autopilot

# use PX4 helper to install ubuntu deps (this is the official convenience script)
bash ./Tools/setup/ubuntu.sh
```
Notes:
ubuntu.sh installs required system packages and simulation dependencies for Ubuntu 22.04. Run it and read its output. If you’re in a container or already modified your system, check the script before running. (https://github.com/PX4/PX4-Autopilot/blob/main/Tools/setup/ubuntu.sh?utm_source=chatgpt.com)

# 2 — Build PX4 SITL (quick start)
You don’t need Gazebo for AirSim HIL. Use the none target.
```bash
cd ~/PX4-Autopilot
# optional cleanup if you had broken builds
make distclean

# build SITL core (no GUI)
make px4_sitl none
```
If you prefer none_iris for a multirotor default: make px4_sitl none_iris. If you get “server already running” kill px4 processes: pkill -f px4 || true.

If you need the NSH prompt later, use the PX4 interactive launcher (the build scripts already configure proper working dirs). If tmux isn’t used, start the interactive instance explicitly from the project root:
```bash
# only if you need NSH interactive (rare)
build/px4_sitl_default/bin/px4 -w rootfs -s etc/init.d-posix/rcS
```

# 3 — Download and install AirSim (prebuilt Blocks) — easiest path
Grab the prebuilt Linux Blocks environment from the AirSim releases page. Pick the latest Linux Blocks zip.
```bash
cd $HOME
# Replace the URL with the Blocks.zip asset from the latest release page
wget https://github.com/microsoft/AirSim/releases/download/v1.4.0-linux/Blocks.zip -O Blocks.zip
unzip Blocks.zip -d ~/AirSim/Blocks
```
You should end up with a LinuxNoEditor folder, e.g.:
```bash
~/AirSim/Blocks/LinuxNoEditor/Blocks.sh
```
If you built AirSim or the UE project from source you can package it, but that requires Unreal Engine (painful). Prebuilt is fastest. (https://github.com/microsoft/airsim/releases?utm_source=chatgpt.com)

# 4 — Install QGroundControl (AppImage)
Download the latest AppImage from QGC releases and make it executable:
```bash
cd $HOME/Downloads
# download the latest QGC AppImage from releases (or use the link on docs)
wget https://github.com/mavlink/qgroundcontrol/releases/download/v5.0.8/QGroundControl.AppImage -O QGroundControl.AppImage
chmod +x QGroundControl.AppImage
# optional: move to /opt or ~/bin
mv QGroundControl.AppImage ~/QGroundControl.AppImage
```
install any recommended libs (some distributions need these):
```bash
sudo apt install -y gstreamer1.0-plugins-bad gstreamer1.0-libav gstreamer1.0-gl libfuse2 libxcb-xinerama0
```
Then run:
```bash
~/QGroundControl.AppImage
```
Docs: QGroundControl install instructions. (https://docs.qgroundcontrol.com/master/en/qgc-user-guide/getting_started/download_and_install.html?utm_source=chatgpt.com)

# 5 — Configure AirSim for PX4 HIL
Create the AirSim config directory and put this settings.json there:
```bash
mkdir -p ~/.config/AirSim
cat > ~/.config/AirSim/settings.json <<'JSON'
{
  "SettingsVersion": 1.2,
  "SimMode": "Multirotor",
  "ClockSpeed": 1,
  "Vehicles": {
    "PX4": {
      "VehicleType": "PX4Multirotor",
      "UseSerial": false,
      "UseTcp": true,
      "TcpPort": 4560,
      "ControlIp": "127.0.0.1",
      "ControlPort": 14540,
      "UdpPort": 14560,
      "X": 0, "Y": 0, "Z": -1,
      "Pitch": 0, "Roll": 0, "Yaw": 0
    }
  },
  "OriginGeopoint": {
    "Latitude": 47.397742,
    "Longitude": 8.545594,
    "Altitude": 488.0
  }
}
JSON
```
Short explanation:
* AirSim listens for PX4 SITL on TCP 4560.
* AirSim forwards control to PX4 on UDP 14540 (PX4 expects it).
* PX4 may send sensor/HIL info on UDP 14560.
* QGC listens on UDP 14550 for GCS telemetry. (You’ll make sure PX4 has that GCS endpoint.)
If you plan to run multiple vehicles, adjust ports per vehicle.

# 6 — Start sequence (do not improvise)
Open three terminals (PX4, AirSim, QGC) and start in this order:

# A — PX4 SITL
```bash
cd ~/PX4-Autopilot
make px4_sitl none
# or for a specific vehicle:
# make px4_sitl none_iris
```
Wait for PX4 to settle. It will print messages like Waiting for simulator to accept connection on TCP port 4560.

# B — AirSim Blocks (prebuilt)
```bash
cd ~/AirSim/Blocks/LinuxNoEditor
# prefer OpenGL if Vulkan errors occur on your machine:
export RHI=OpenGL
export SDL_VIDEODRIVER=x11
./Blocks.sh -opengl4
# or run the binary directly:
# ./Blocks/Binaries/Linux/Blocks-Linux-Shipping -opengl4
```
AirSim DroneServer will connect to PX4 over TCP 4560; the AirSim log should show Connected to SITL over TCP.

If you have no GPU or Blocks keeps crashing, try headless mode:
```bash
./Blocks.sh -nullrhi
```
# C — QGroundControl
Start QGC AppImage:
```bash
~/QGroundControl.AppImage
```
If QGC doesn’t auto-detect a vehicle, add a UDP link:
* Host: 127.0.0.1
* Port: 14550
If you see telemetry (attitude, battery, GPS) you’re golden.

# 7 — Verify MAVLink endpoints (inside PX4 NSH)
If QGC shows nothing, open PX4’s NSH shell and check:

Attach to tmux or use an interactive instance. If tmux is used:
```bash
tmux attach -t px4
# switch to NSH pane until you see `nsh>` or `pxh>`
nsh> mavlink status
```
ou should see instances for:
* TCP 4560 (simulator)
* UDP 14540 (control to/from AirSim)
* UDP 14550 (GCS) — if present. If 14550 is missing, create it:
```bash
nsh> mavlink start -u 14550 -r 400000
```
After that, QGC (UDP 14550) should get telemetry.

# — HIL notes & tips
* AirSim is the sensor/data source: it sends simulated IMU, baro, magnetometer, GPS via MAVLink. PX4 receives these sensor MAVLink messages and behaves as if HIL sensors were attached.
* For standard HIL testing you typically do not need to change PX4 parameters, but you may want to use a PX4 HIL-specific autostart script or a SITL startup file with SYS_AUTOSTART set for your vehicle.
* Always use PX4 → AirSim → QGC start order. Reversing leads to connection flapping.
* If AirSim/Blocks crashes on startup: try -opengl4 or -nullrhi. On Intel GPUs, OpenGL is often more stable than Vulkan. See AirSim docs. (https://microsoft.github.io/AirSim/use_precompiled/?utm_source=chatgpt.com)

# 9 — Handy launcher script
Create start_hil.sh to automate:
```bash
cat > ~/start_hil.sh <<'BASH'
#!/usr/bin/env bash
set -euo pipefail
# Terminal 1: PX4
gnome-terminal -- bash -ic "cd ~/PX4-Autopilot && make px4_sitl none; exec bash" &

# wait a few seconds for PX4 to set up
sleep 6

# Terminal 2: AirSim (Blocks)
gnome-terminal -- bash -ic "cd ~/AirSim/Blocks/LinuxNoEditor && export RHI=OpenGL SDL_VIDEODRIVER=x11 && ./Blocks.sh -opengl4; exec bash" &

sleep 4

# Terminal 3: QGroundControl
gnome-terminal -- bash -ic "~/bin/QGroundControl.AppImage; exec bash" &

echo "Launched PX4, AirSim, QGC. Watch their windows/logs."
BASH

chmod +x ~/start_hil.sh
```
Run it with ~/start_hil.sh. Replace gnome-terminal with your terminal emulator (e.g. konsole, xfce4-terminal) if you’re not using GNOME.

# 10 — Troubleshooting (the usual suspects)

**AirSim crashes (segfault)**
* Use -opengl4 or -nullrhi. Intel drivers and Vulkan frequently cause runtime crashes. If you have weak/no GPU, prefer -nullrhi. (https://microsoft.github.io/AirSim/use_precompiled/?utm_source=chatgpt.com)

**QGC shows no vehicle**
* Confirm mavlink status inside PX4 shows a 14550 instance. If missing: mavlink start -u 14550 -r 400000.
* Ensure QGC UDP link uses port 14550.

**PX4 shows** poll timeout 0, 111
* Common. Usually harmless if telemetry works. If telemetry missing, AirSim is repeatedly connecting/disconnecting — re-check ports and start order.

**PX4 build errors (CMake/Gazebo classic)**
* You can skip Gazebo Classic by using make px4_sitl none and by not building/using gazebo-classic. If you must build the modern sim stack, follow PX4 docs (ubuntu helper). (https://docs.px4.io/main/en/dev_setup/dev_env_linux_ubuntu?utm_source=chatgpt.com)

**Permissions / AppImage issues**
* Install libfuse2 and gstreamer plugins if QGC AppImage fails to start. (https://docs.qgroundcontrol.com/master/en/qgc-user-guide/getting_started/download_and_install.html?utm_source=chatgpt.com)

# 11 — Tips for sharing with the community
* Include the exact versions you used (PX4 git tag: git describe --tags; AirSim release tag; QGroundControl version).
* Share settings.json, start_hil.sh, and any mavlink start ... commands you needed.
* If posting logs, include: PX4 mavlink status output, AirSim console lines showing TCP connect, and last 200 lines of Blocks/Saved/Logs/Blocks.log if AirSim crashed.

# Example minimal checklist you can paste in a forum post
```bash
OS: Ubuntu 22.04
PX4: main branch (git describe --tags -> v1.xx.x)
AirSim: Blocks.zip (airsim release vX.Y.Z)
QGC: QGroundControl.AppImage v5.x

Steps:
1) bash PX4-Autopilot/Tools/setup/ubuntu.sh
2) git clone PX4-Autopilot --recursive
3) make px4_sitl none
4) unzip Blocks.zip -> ~/AirSim/Blocks
5) put settings.json into ~/.config/AirSim/
6) run Blocks.sh -opengl4
7) run QGroundControl.AppImage
8) in PX4 nsh: mavlink status ; if no 14550: mavlink start -u 14550 -r 400000
```

# Final note (because the world is messy)
This stack (PX4 + AirSim + QGC) works reliably if the software versions and ports are aligned and if you have at least a modest GPU or use headless options. If you run into a specific error, paste the exact terminal output — that’s how I diagnose the nonsense. If you want, I can generate a ready-to-paste GitHub Gist from this README with a few launch scripts and settings.json files tailored to your machine. No small talk. Just files.
