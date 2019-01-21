# pyunramura/transmission
[![](https://images.microbadger.com/badges/image/pyunramura/transmission:2.94.svg)](https://microbadger.com/images/pyunramura/transmission:2.94 "MicroBadger.com info on my Docker image")
[![](https://images.microbadger.com/badges/version/pyunramura/transmission:2.94.svg)](https://hub.docker.com/r/pyunramura/transmission "Link to Docker Hub project")
[![](https://images.microbadger.com/badges/commit/pyunramura/transmission:2.94.svg)](https://hub.docker.com/u/pyunramura "Link to my Docker Hub profile")
[![](https://img.shields.io/github/license/pyunramura/docker-openvpn.svg?logo=github&logoColor=white)](https://github.com/pyunramura/docker-transmission/blob/master/LICENSE "Link to the license")
[![](https://img.shields.io/github/languages/top/pyunramura/docker-transmission.svg?colorB=green&logo=gnu&logoColor=white)](https://github.com/pyunramura/docker-transmission "Link to my Github project")

## How to use this image

This container is configured to be used in conjunction with my [OpenVPN](https://github.com/pyunramura/openvpn) client and set up for automatic out-of-the-box port-forwarding to capable [private internet access](https://www.privateinternetaccess.com/helpdesk/kb/articles/how-do-i-enable-port-forwarding-on-my-vpn) servers for faster downloads. Additional support for port-forwarding capable vpn providers can be added on request. Feedback is welcome and encouraged as I'm always looking to improve my containers.

[![](https://i.imgur.com/GZqRBms.png)](https://transmissionbt.com/ "Link to Transmission.com website")

Transmission is an amazingly simple but powerful open-source torrent client that is heavily optimized to run on devices ranging from server-grade architectures to energy-efficient arm devices. It forgoes some of the bells and whistles of other torrent clients in favor of a streamlined process that is light on resources, so it is a shoe-in for use in docker containers. To learn more about it, visit its webpage at [transmissionbt.com](http://www.transmissionbt.com/about/)

This image is based on Alpine Linux with s6-overlay and optimized to be light-weight and feature robust process management. 
Additionally this container is heavily modeled after the fantastic [linuxserver.io](https://hub.docker.com/u/linuxserver/) containers, but with added features and more aggressive space-saving techniques.

## Usage Example with a VPN

```
docker run -d --rm \
  --name=transmission \
  --net=container:openvpn \
  -v path/to/config/data:/config \
  -v path/to/downloads:/downloads \
  -v path/to/watch/dir:/watch \
  -v vpn_port:/var/run/openvpn \
  -e GID=783 -e UID=783 \
  -e VPN=yes -e PORT_F=yes \
  -e NEW_UI=yes 
  pyunramura/transmission
```
## Usage Example without a VPN

```
docker run -d --rm \
  --name=transmission \
  -p 9091:9091 -p 51413:51413 \
  -p 51413:51413/udp \
  -v path/to/config/data:/config \
  -v path/to/downloads:/downloads \
  -v path/to/watch/dir:/watch \
  -e GID=783 -e UID=783 \
  -e NEW_UI=yes 
  pyunramura/transmission
```

# Parameters

`The parameters below are split into two halves, separated by a colon, the left hand side representing the host and the right the container side.`

For example with `-p external:internal` - what this shows is the port mapping from external to internal of the container.
So -p 80:9091 would expose port 9091 from inside the container to be accessible from the host's IP on port 80
http://192.168.x.x:80 would show you what's running INSIDE the container on port 9091.

  * `-p 9091`  - the default port for the transmission-web UI
  * `-p 51413`  - the default peer port for use in non vpn based port forwarding
  * `-v /config`  - where transmission will store its configuration files and logs
  * `-v /downloads`   - for your local path for downloaded torrents
  * `-v /watch`  - the folder for dropped-in .torrent files to be automatically picked up by transmission
  * `-v vpn_port`  - a docker volume made with `docker create volume` to retrieve the peer port if used with my OpenVPN container
  * `-e GID`  - for GroupID - see below for explanation
  * `-e UID`  - for UserID - see below for explanation
  * `-e VPN`  - if set to **yes**, the container will automatically attach itself to a connected open vpn tunnel, and kill the connection if it goes down
  * `-e PORT_F`  - if set to **yes**, your peer port will be dynamically updated if used along-side my [OpenVPN](https://github.com/pyunramura/openvpn) container
  * `-e NEW_UI`  - if set to **yes**, enables Secretmapper's modern [Combustion UI](https://github.com/Secretmapper/combustion) in place of the default transmission-web UI

#### Notes from above
* The `51413` port-mapping is only useful for peer-peer communication when running standalone, it can be forwarded through your firewall, or UPnP if needed.
* The default ports are not needed for the `--net=container:openvpn` option, they will be mapped to it instead. If you are using this option in a docker-compose file it would instead read `network_mode: service:openvpn`. A sample compose file is in the [openvpn](https://github.com/pyunramura/docker-openvpn) repository for reference.
* The container implements a kill switch to rebind the service to _localhost_ if the vpn tunnel collapses as an additional privacy measure against leaking unwanted data. This is set to run every 10 minutes at default and can be changed if requested.

## User / Group Identifiers

Sometimes when using data volumes (`-v` flags) permissions issues can arise between the host OS and the container. This is avoided by allowing you to specify the user `UID` and group `GID`. Ensure the data volume directory on the host is owned by the same user you specify and it will "just work" ™.

In this instance for `UID=1001` and `GID=1001`. To find yours, use `id user` as below:

```
  $ id <dockeruser>
    uid=1001(dockeruser) gid=1001(dockergroup) groups=1001(dockergroup)
```

## Setting up the application 

The transmission-web UI is on port 9091, the _settings.json_ file in /config has extra settings not available in the web UI. You will need to stop the container before editing it or your changes won't be saved. 

There are many more configuration options housed in Transmission's `settings.json` that can be edited as you see fit. The guide for this can be found at the [Transmision Github Wiki](https://github.com/transmission/transmission/wiki/Editing-Configuration-Files).

## Securing the web UI with a username and password.

This requires 3 settings to be changed in the _settings.json_ file.

`Make sure the container is stopped before editing these settings.`

`"rpc-authentication-required": true,` - check this, the default is false, change to true.

`"rpc-username": "transmission",` substitute transmission for your chosen user name, this is just an example.

`rpc-password` will be a hash starting with {, replace everything including the { with your chosen password, keeping the quotes.

Transmission will convert it to a hash when you restart the container after making the above changes.

## Updating blocklists Automatically

This setting requires `"blocklist-enabled": true,` to be set in the _settings.json_. By setting this to true, it is assumed you have also populated `blocklist-url` with a valid block list.

The automatic update will run once a day at 3am local server time.

This setting should not be necessary if used behind a vpn.

## Info

* For shell access while the container is running

   `docker exec -it transmission /bin/sh`.

* To monitor the logs of the container in realtime

   `docker logs -f transmission`.

* For the container version number

   `docker inspect -f '{{ index .Config.Labels "build_version" }}' transmission`.

* For the image version number

   `docker inspect -f '{{ index .Config.Labels "build_version" }}' pyunramura/transmission`.

# Troubleshooting

### Initial setup

You will need to start, then stop the container in order to generate the `settings.json` in order to edit the file.

If you will not be needing to traffic your torrents through the VPN, leave `-e VPN` unset as it will trigger the container to fail and exit if not set to **yes**. This is designed as a check to make sure that you want to enable the kill switch that the `-e VPN=yes` option enables.

* If you have any other problems or comments about using this container, please reach out to me through the "Issues" tab as feedback and bug reports are welcome and encouraged.

## Versions

+ **2.9.4-r0** - Initial Release.

