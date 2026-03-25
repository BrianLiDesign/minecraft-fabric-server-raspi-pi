# Raspberry Pi Fabric Minecraft Server

## Table of Contents

1. [Project Description](#project-description)
2. [Getting Started](#getting-started)
   - [Prerequisites](#prerequisites)
   - [Installation](#installation)
3. [Usage](#usage)
   - [Start/Stop/Restart](#startstoprestart)
   - [View Logs](#view-logs)
   - [Backups](#backups)
   - [Update Fabric](#update-fabric)
   - [Datapacks](#datapacks)
4. [Troubleshooting](#troubleshooting)
5. [Contact](#contact)
6. [Acknowledgments](#acknowledgments)

## Project Description

This repository contains the scripts and service configuration needed to run a **Fabric Minecraft server** reliably on a Raspberry Pi. Instead of keeping the server tied to an SSH session, the server is managed by **systemd**, which keeps it running in the background, can start it automatically at boot, and provides centralized logs via `journalctl`.

The goal is a clean, GitHub-friendly setup that avoids committing huge or sensitive server data (world files, jars, logs, secrets). The repo includes:

- A launch script (`start.sh`) for consistent server startup
- A systemd unit (`minecraft.service`) for automatic background hosting
- A backup script (`backup.sh`) that saves your world + mods + datapacks
- An update script (`update.sh`) to refresh Fabric server files for a target Minecraft version

### Built With

![Linux Badge][linux-badge]
![Raspberry Pi Badge][raspberry-pi-badge]
![Java Badge][java-badge]
![Fabric Badge][fabric-badge]
![Systemd Badge][systemd-badge]

## Getting Started

### Prerequisites

- Raspberry Pi 4/5 (recommended) running **Raspberry Pi OS 64-bit**
- Java **21** installed
- A Fabric server directory, e.g. `~/mc-fabric`
- Basic SSH access (optional but recommended)

### Installation

1.  Clone the repository

    ```bash
    git clone https://github.com/BrianLiDesign/minecraft-fabric-server-raspberry-pi.git
    cd minecraft-fabric-server-raspberry-pi
    ```

2.  Copy scripts into your server directory (or set SERVER_DIR to match your layout)

    Recommended layout:

    ~/mc-fabric/

    ├── fabric-server-launch.jar

    ├── server.properties

    ├── mods/

    ├── world/

    └── start.sh

3.  Create the server start script

    Copy scripts/start.sh (or create your own) into your server folder:

    ```
    cp scripts/start.sh ~/mc-fabric/start.sh
    chmod +x ~/mc-fabric/start.sh
    ```

4.  Install the systemd service

    ```
    sudo cp systemd/minecraft.service /etc/systemd/system/minecraft.service
    sudo systemctl daemon-reload
    sudo systemctl enable minecraft
    sudo systemctl start minecraft
    ```

5.  Confirm it’s running

    ```
    sudo systemctl status minecraft --no-pager
    ```

> [!WARNING]
> Do not run java -jar ... manually if systemd is managing the server, or you may start multiple servers and cause lag/port conflicts.

## Usage

### Start/Stop/Restart

    sudo systemctl start minecraft
    sudo systemctl stop minecraft
    sudo systemctl restart minecraft

### View Logs

Follow logs live (this is the “console output” when using systemd):

    sudo journalctl -u minecraft -f

View recent logs:

    sudo journalctl -u minecraft -n 200 --no-pager

### Backups

Backups include:

    - World folder (auto-detected via `level-name`)

    - `config/` folder (if present)

    - `mods/` folder

    - `world/datapacks/` (included because it’s inside the world)

    - Common server config files (`server.properties`, `eula.txt`, whitelist/ops/bans, etc.)

Run:

    ./scripts/backup.sh

Backups are written to: `~/mc-backups/`

Override backup location:

    BACKUP_DIR=~/backups ./scripts/backup.sh

### Update Fabric

This updates Fabric server files for a target Minecraft version (example below uses 1.21.1):

    ./scripts/update-fabric.sh 1.21.1

Recommended update flow:

    sudo systemctl stop minecraft
    ./scripts/backup.sh
    ./scripts/update-fabric.sh 1.21.1
    sudo systemctl start minecraft

Mods are not auto-updated. Many mods must be updated per Minecraft version.

### Datapacks

Datapacks must be placed in the world folder:

    ~/mc-fabric/world/datapacks/

Each datapack should be either:

- A folder containing `pack.mcmeta` and `data/`, or
- A `.zip` containing `pack.mcmeta` and `data/`

## Troubleshooting

### `Permission denied` when running scripts

Your shell scripts may not be marked as executable.

Fix with:

    chmod +x start.sh
    chmod +x scripts/backup.sh
    chmod +x scripts/update.sh

If you are using systemd, also make sure the service is running as a user that has permission to access the server folder.

### Cannot connect to the server from another device

First confirm the server is actually running and listening on the expected port.

Check:

    sudo systemctl status minecraft.service
    ss -tulpn | grep 25565

Then verify:

- The Raspberry Pi’s local IP address is correct
- Port 25565 is allowed through your firewall
- Your router port forwarding is set up correctly for external access
- Everyone is using the same Minecraft version and mod setup

For local network play, connect using the Pi’s LAN IP:

    hostname -I

### Getting Help

When debugging, these commands usually reveal the problem fastest:

    sudo systemctl status minecraft.service
    journalctl -u minecraft.service -n 100 --no-pager
    java -version
    ls -lah

If you open an issue, include:

- Raspberry Pi model
- Raspberry Pi OS version
- Java version
- Minecraft / Fabric version
- The exact error message
- Relevant service logs

## Contact

Brian Li - brian.li.social@gmail.com

## Acknowledgments

- FabricMC community for Fabric tooling and documentation
- Raspberry Pi community for Linux + Pi server resources

<!-- MARKDOWN LINKS & IMAGES -->

[linux-badge]: https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black&labelColor=white
[raspberry-pi-badge]: https://img.shields.io/badge/-RaspberryPi-C51A4A?style=for-the-badge&logo=Raspberry-Pi&labelColor=black
[java-badge]: https://img.shields.io/badge/java-%23ED8B00?style=for-the-badge&logo=openjdk&logoColor=white&labelColor=black
[fabric-badge]: https://img.shields.io/badge/fabric-fabric?style=for-the-badge&color=gray
[systemd-badge]: https://img.shields.io/badge/systemd-systemd?style=for-the-badge&color=blue
