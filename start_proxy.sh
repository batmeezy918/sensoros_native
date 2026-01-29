#!/data/data/com.termux/files/usr/bin/bash
cd ~/sensoros_cloud
nohup python proxy_rebuild_agent.py > proxy.log 2>&1 &
echo "RTAG Proxy started"
