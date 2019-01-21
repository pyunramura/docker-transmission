#!/usr/bin/env sh
SERVICE=transmission-daemon
SETTINGS=/config/settings.json
PARAM=peer-port
PORT=$(cat /var/run/openvpn/vpn_port)
CONFIG=`cat $SETTINGS | jq '.["peer-port"]' | sed 's/"//g'`
MODCFG=`cat $SETTINGS | sed "s/.*$PARAM.*/    \"$PARAM\"\: $PORT,/g" > temp.json`
change_settings () {
  s6-svc -wD -d /var/run/s6/services/transmission
  $MODCFG
  chown abc:abc temp.json
  mv temp.json /config/settings.json
  s6-svc -wu -u /var/run/s6/services/transmission
  break ;
}
case "$PORT_F" in
     yes) if [ ! "$PORT" = "$CONFIG" ]; then
          echo "[system.d] [INFO] changing $SERVICE $PARAM to $PORT"
          change_settings; else
          if [ "$PORT" = "" ]; then
          echo "[system.d] [WARN] PORT_F=yes, check that /var/run/openvpn/vpn_port is accessible"
          fi
          fi ;;
       *) break ;;
esac
exit 0
