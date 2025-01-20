#!/bin/bash
set -e
MODLIST="${GAME_DIR}/steamapps/workshop/appworkshop_440900.acf"

_terminate() {
  echo "Caught TERM signal!"
  echo "Stopping Conan Exiles"
  wineserver -k -w
  /etc/init.d/xvfb stop
}

if [ -z "${GAME_INSTANCE_NAME}" ]; then
  echo "Please define GAME_INSTANCE_NAME game variable to give your instance a name."
  exit 1
fi

DOWNLOAD_TYPE="update"
if [ ! -d "${GAME_DIR}/.wine" ]; then
  echo "First time start, init wineboot."
  DOWNLOAD_TYPE="download"
  GAME_UPDATE=true
fi

if [ "$GAME_UPDATE" = true ]; then
  echo "Start game ${DOWNLOAD_TYPE}..."
  steamcmd +force_install_dir "${GAME_DIR}" +login anonymous +@sSteamCmdForcePlatformType windows +app_update "${APP_ID}" validate +quit
  echo "Game ${DOWNLOAD_TYPE} done."
fi

if [ ! -d "${GAME_DIR}/ConanSandbox/${GAME_INSTANCE_NAME}" ]; then
  echo "Link config dir ${GAME_DIR}/ConanSandbox/${GAME_INSTANCE_NAME}"
  ln -s "${CONFIG_DIR}" "${GAME_DIR}/ConanSandbox/${GAME_INSTANCE_NAME}"
fi

if [ -n "${GAME_SERVER_NAME}" ]; then
  SERVER_NAME_PARAM="-ServerName=${GAME_SERVER_NAME}"
fi

if [ -n "${GAME_SERVER_PASSWORD}" ]; then
  SERVER_PASSWORD_PARAM="-ServerPassword=${GAME_SERVER_PASSWORD}"
fi

if [[ ${GAME_MOD_IDS} =~ ^[0-9,]+$ ]]; then
  for mod_id in ${GAME_MOD_IDS//,/ }
  do
    if [ -f "${MODLIST}" ] && grep -q "${mod_id}" "${MODLIST}"; then
      echo "Mod ${mod_id} already installed, skipping."
      continue
    fi
    echo "Adding Mod ${mod_id}."
    MODS_CMD="${MODS_CMD} +workshop_download_item ${APP_ID_MODS} ${mod_id}"
  done
  if [ -n "${MODS_CMD}" ]; then
    echo "Installing Mod(s)."
    steamcmd +force_install_dir "${GAME_DIR}" +login anonymous @sSteamCmdForcePlatformType windows "${MODS_CMD}" +quit
  fi
fi

trap _terminate HUP INT QUIT TERM SIGTERM

/etc/init.d/xvfb start
wine ConanSandboxServer.exe --userdir="${GAME_INSTANCE_NAME}" "${SERVER_NAME_PARAM}" "${SERVER_PASSWORD_PARAM}" \
    "${SERVER_ADDITIONAL_PARAMETER}" -nosteamclient -game -server -log &
tail -f "${CONFIG_DIR}/Saved/Logs/ConanSandbox.log" &

wait
