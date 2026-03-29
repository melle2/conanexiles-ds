FROM melle2/wine-steamcmd-ubuntu:24.04-3

ARG USER_ID=7100
ARG GROUP_ID=7100

ENV USER_NAME=conanexiles \
    APP_ID=443030 \
    APP_ID_MODS=440900 \
    WINEARCH="win64"
ENV HOME_DIR=/home/${USER_NAME} \
    GAME_DIR=/${USER_NAME}
ENV WINEPREFIX=${GAME_DIR}/.wine


RUN apt update && apt dist-upgrade -y && apt install -y winbind && \
    groupadd -g ${GROUP_ID} ${USER_NAME} && useradd -u ${USER_ID} -g ${GROUP_ID} -m ${USER_NAME} &&  \
    mkdir ${CONFIG_DIR} "${HOME_DIR}/.steam"

ADD startConanExiles.sh ${HOME_DIR}
RUN chmod 744 ${HOME_DIR}/startConanExiles.sh && chown -R ${USER_ID}:${GROUP_ID} ${CONFIG_DIR} ${HOME_DIR}

USER ${USER_NAME}
WORKDIR /${GAME_DIR}
ENV WINEDEBUG=fixme-all,err+all
ENV XDG_RUNTIME_DIR="/tmp/runtime-conanexiles"

RUN mkdir -p ${XDG_RUNTIME_DIR} && chmod 700 ${XDG_RUNTIME_DIR} && chown ${USER_ID}:${GROUP_ID} ${XDG_RUNTIME_DIR}

ENTRYPOINT ["/home/conanexiles/startConanExiles.sh"]

EXPOSE 7777 7778 27015
