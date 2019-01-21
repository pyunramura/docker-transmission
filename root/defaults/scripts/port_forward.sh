#!/usr/bin/env sh
SERVICE=transmission-daemon
PARAM=peer-port
PORT=$(cat /var/run/openvpn/vpn_port)
sleep 20
if [ ! "$PORT" = "" ]; then
  /usr/bin/transmission-remote --port $PORT
  echo "[services.d] [INFO] $SERVICE $PARAM was updated to $PORT"; else
    echo "[services.d] [WARN] $SERVICE $PARAM is unavailable; check that the vpn tunnel is up"
fi
exit 0
