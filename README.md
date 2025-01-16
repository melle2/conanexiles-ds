## Conan Exiles Dedicated Server

This image is based on wine, Xvfb and SteamCMD. It is a basic image so that Conan Exiles is able to get installed on
your host and being executed.

## What you should know

1. This image is based on another "basic image" (wine-steamcmd-ubuntu), which I've created to not only use it for Conan
   Exiles, but also for all other kind of Windows based dedicated game servers.
2. You should have a basic understanding how to deal with Docker and Linux. All documentation is based on a Linux
   environment. However, it is possible to run this also in a Windows environment if you install Docker/K8s.
3. Internally the dedicated server is executed as user/group `conanexiles` - UserID 7100, GroupId 7100.

## How to start

1. Create a `conanexiles` folder on your host environment.
2. You must change the owner:group of your target folder to 7100:7100.

### Volume

Within the image, ConanExiles Dedicated Server is installed to folder `/conanexiles`. The folder structure is set up in
the way that the pure game files resist in folder `/conanexiles` and your world database and configuration files in the
folder `/conanexiles_config`.
Internally the Configuration folder is then linked into the game folder, and you can decide if you only want to mount
the config folder or additionally the game folder as well. In case you want to mount both, you can set up something like
this:
`/srv/data/conanexiles/game` --> mounted to `/conanexiles` (not needed)
`/srv/data/conanexiles/config` --> mounted to `/conanexiles_config` (you should, you might lose your world otherwise)
With this it is mandatory to define the `GAME_INSTANCE_NAME` environment variable, otherwise this setup doesn't work.
This concept gives you full control about your configuration files and backups of your world and config , in my view, is
easier.

### Ports

If your ports are already blocked by another game, you can change the Conan Exiles Configuration within int ini files in
your config folder.
Consult the official documentation of the Conan Exiles' properties for more information.
Keep in mind, if you start the game from your local network, you have to open the respective ports in your router!

### Environment variables

The only mandatory requirement is to pass the `GAME_INSTANCE_NAME` variable. Additionally, you can set some more
specific environment variables so that you don't need to touch the .ini files.

| Parameter name              |                                                                          Description                                                                          | Default value | Mandatory |
|:----------------------------|:-------------------------------------------------------------------------------------------------------------------------------------------------------------:|--------------:|----------:|
| GAME_INSTANCE_NAME          |                              Sets the instance name of the dedicated sever, which is being passed as a `userdir` for the server                               |             - |       yes |
| GAME_SERVER_NAME            |                              Set the server name. With this name you can find your server in the online server list in the game                               |             - |        no |
| GAME_SERVER_PASSWORD        |                                                        Set the game password to login into the server.                                                        |             - |        no |
| GAME_MOD_IDS                | Comma separated list of mod is which are being installed before server start. In any case you must configure them by yourself in the ini files, if necessary! |             - |        no |
| GAME_UPDATE                 |                              With this parameter you are able to update the game to the latest available version before startup                               |         false |        no |
| SERVER_ADDITIONAL_PARAMETER |           To give you more control for the command line, you can pass additional game parameter, i.e. for multi server setup (I never tried this).            |             - |        no |

### Docker

Example (minimal) docker run command:

```
docker run -d \
	--name conanexiles-dedicated-server \
	-p 27015:27015/udp \
	-p 7777:7777/udp \
	-p 7778:7778/udp \
	-e GAME_INSTANCE_NAME=<instance_name> \
	-v /srv/data/conanexiles/game:/conanexiles \
    -v /srv/data/conanexiles/config:/conanexiles_config
	melle2/conanexiles-ds:latest
```

### Docker Compose

Example docker-compose yaml configuration

```
services:
  conanexiles:
    container_name: conanexiles-dedicated-server
    image: melle2/conanexiles-ds:latest
    restart: always
    environment:
      TZ: Europe/Berlin
      GAME_INSTANCE_NAME: <instance_name>
      GAME_SERVER_NAME: <your_server_name>
      GAME_SERVER_PASSWORD: <password>
      GAME_MOD_IDS: <11111,22222,33333>
      GAME_UPDATE: <true/false>
      SERVER_ADDITIONAL_PARAMETER: <additional_parameter>
    ports:
        - 7777:7777/udp
        - 7778:7778/udp
        - 27015:27015/udp
    volumes:
        - /srv/data/conanexiles/game:/conanexiles
        - /srv/data/conanexiles/config:/conanexiles_config
```

### DockerHub

Docker Image is available at https://hub.docker.com/repository/docker/melle2/conanexiles-ds.
`docker pull melle2/conanexiles-ds`

### Improvements

If you see improvements, feel free to contribute and create a PR.

## DISCLAIMER!!

I've tested the image/setup on my VPS. On the environment everything worked as expected. Not only a completely new game,
but I was even able to start my old game which some time had been created from the implementation by alinmear
at https://github.com/alinmear/docker-conanexiles. But as this project is not maintained anymore I've created my own
Docker image.
However, as I don't know each and every setup, it could be that something is not working as expected.
