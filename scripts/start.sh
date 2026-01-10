[Unit]
Description=Minecraft Fabric Server
After=network-online.target
Wants=network-online.target

[Service]
User=brianlidesign
WorkingDirectory=/home/brianlidesign/mc-fabric
ExecStart=/home/brianlidesign/mc-fabric/start.sh

Restart=on-failure
RestartSec=10

# Allow lots of open files
LimitNOFILE=100000

# Time to save on stop/restart
KillSignal=SIGINT
TimeoutStopSec=60

[Install]
WantedBy=multi-user.target
