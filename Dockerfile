FROM melle2/wine-steamcmd-ubuntu:latest

ARG UUID=7100

ENV USER_NAME=conanexiles \
    APP_ID=443030 \
    APP_ID_MODS=440900 \
    WINEARCH="win64" \
    CONFIG_DIR=/conanexiles_config
ENV HOME_DIR=/home/${USER_NAME} \
    GAME_DIR=/${USER_NAME}
ENV WINEPREFIX=${GAME_DIR}/.wine


RUN apt install -y winbind && \
    groupadd -g ${UUID} ${USER_NAME} && useradd -u ${UUID} -g ${UUID} -m ${USER_NAME} &&  \
    mkdir ${CONFIG_DIR} "${HOME_DIR}/.steam"

ADD startConanExiles.sh ${HOME_DIR}
RUN chmod 744 ${HOME_DIR}/startConanExiles.sh && chown -R ${UUID}:${UUID} ${CONFIG_DIR} ${HOME_DIR}

USER ${USER_NAME}
WORKDIR ${GAME_DIR}

ENTRYPOINT ["/home/conanexiles/startConanExiles.sh"]

EXPOSE 7777 7778 27015
