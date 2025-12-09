# Drone HIL GitHub Template Repo

A ready-to-push repository structure containing PX4 + AirSim + QGC + ROS2 integration helpers, launch scripts, settings, and documentation.

```
drone-hil-template/
├── README.md
├── scripts/
│   ├── install_px4_deps.sh
│   ├── install_airsim.sh
│   ├── install_qgc.sh
│   ├── start_hil.sh
│   ├── start_px4.sh
│   ├── start_airsim.sh
│   ├── start_qgc.sh
│   └── ros2_bridge_launcher.sh
├── airsim/
│   └── settings.json
├── ros2/
│   ├── px4_ros2_bridge.md
│   └── install_ros2_humble.sh
└── qgc/
    └── notes.md
```

---

# README.md

```
# Drone HIL Template (PX4 + AirSim + QGC + ROS2)

This repository provides a minimal, reproducible setup for PX4 SITL + AirSim HIL + QGroundControl + optional ROS2 integration.
Tested on Ubuntu 22.04.

## Structure
- scripts/: one-click installers and launchers
- airsim/: settings.json for PX4 HIL
- ros2/: ROS2 + PX4 bridge setup
- qgc/: notes

## Quickstart
```

```bash
./scripts/install_px4_deps.sh
./scripts/install_airsim.sh
./scripts/install_qgc.sh

# Then run HIL
./scripts/start_hil.sh
```

```

---
# scripts/install_px4_deps.sh
```

#!/usr/bin/env bash
set -e
sudo apt update
sudo apt install -y git python3 python3-pip
cd $HOME
git clone [https://github.com/PX4/PX4-Autopilot.git](https://github.com/PX4/PX4-Autopilot.git) --recursive
cd PX4-Autopilot
bash ./Tools/setup/ubuntu.sh

```
```

---

# scripts/install_airsim.sh

```
#!/usr/bin/env bash
set -e
mkdir -p ~/AirSim
cd ~/AirSim
wget https://github.com/microsoft/AirSim/releases/download/v1.4.0-linux/Blocks.zip -O Blocks.zip
unzip Blocks.zip -d Blocks
```

```

---
# scripts/install_qgc.sh
```

#!/usr/bin/env bash
set -e
cd $HOME/Downloads
wget [https://github.com/mavlink/qgroundcontrol/releases/latest/download/QGroundControl.AppImage](https://github.com/mavlink/qgroundcontrol/releases/latest/download/QGroundControl.AppImage) -O QGroundControl.AppImage
chmod +x QGroundControl.AppImage
mv QGroundControl.AppImage ~/bin/QGroundControl.AppImage
sudo apt install -y libfuse2 gstreamer1.0-plugins-bad gstreamer1.0-libav gstreamer1.0-gl

```
```

---

# scripts/start_px4.sh

```
#!/usr/bin/env bash
cd ~/PX4-Autopilot
make px4_sitl none
```

```

---
# scripts/start_airsim.sh
```

#!/usr/bin/env bash
cd ~/AirSim/Blocks/LinuxNoEditor
export RHI=OpenGL
export SDL_VIDEODRIVER=x11
./Blocks.sh -opengl4

```
```

---

# scripts/start_qgc.sh

```
#!/usr/bin/env bash
~/bin/QGroundControl.AppImage
```

```

---
# scripts/start_hil.sh
```

#!/usr/bin/env bash
set -euo pipefail

gnome-terminal -- bash -ic "$(pwd)/start_px4.sh; exec bash" &
sleep 5
gnome-terminal -- bash -ic "$(pwd)/start_airsim.sh; exec bash" &
sleep 4
gnome-terminal -- bash -ic "$(pwd)/start_qgc.sh; exec bash" &

```
```

---

# airsim/settings.json

```
{
  "SettingsVersion": 1.2,
  "SimMode": "Multirotor",
  "Vehicles": {
    "PX4": {
      "VehicleType": "PX4Multirotor",
      "UseSerial": false,
      "UseTcp": true,
      "TcpPort": 4560,
      "ControlIp": "127.0.0.1",
      "ControlPort": 14540,
      "UdpPort": 14560
    }
  }
}
```

---

# ros2/install_ros2_humble.sh

```
#!/usr/bin/env bash
set -e
sudo apt update && sudo apt upgrade -y
sudo apt install software-properties-common -y
sudo add-apt-repository universe -y
sudo apt update
sudo apt install -y ros-humble-desktop python3-colcon-common-extensions
```

```

---
# ros2/px4_ros2_bridge.md
```

# PX4 + ROS2 Bridge

1. Install ROS2 Humble (script provided).
2. Clone PX4-MicroRTPS-Agent:

````
```bash
git clone https://github.com/PX4/px4-micrortps-agent.git
````

```
3. Generate uORB RTPS messages:

```

```bash
cd ~/PX4-Autopilot
make px4_sitl none rtps
```

```
4. Build agent inside ROS2 workspace.
```

```
```
