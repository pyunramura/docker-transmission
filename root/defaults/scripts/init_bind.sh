#!/usr/bin/with-contenv sh
SERVICE=transmission-daemon
SETTINGS=/config/settings.json
PARAM=bind-address-ipv4
IP=`cat $SETTINGS | jq '.["bind-address-ipv4"]' | sed 's/"//g'`
VPNADDR=`ifconfig | grep -A 5 "tun" | grep "inet" | cut -f12 -d" " | cut -c6-`
MODCFG=`cat $SETTINGS | sed "s/.*$PARAM.*/    \"$PARAM\"\: \"$VPNADDR\",/g" > temp.json`
change_settings () {
  $MODCFG
  chown abc:abc temp.json
  mv temp.json /config/settings.json
  break ;
}
case "$VPNADDR" in
    "") break ;;
     *) change_settings
        echo "[services.d] [INFO] $SERVICE $PARAM was updated to $VPNADDR" ;;
esac 
exit 0
