#!/usr/bin/env bash

################################################
# Lorenzo Cocchi <lorenzo.cocchi@softecspa.it> #
#  script per mantenere solo gli ultimi N      #
#  giorni dei filmati delle webcam della sede  #
#  di Prato - come default mantiene gli        #
#  ultimi  90 giorni                           #
################################################

set -e

VS_PATH="/mnt/videosorveglianza"

DIR_ARCHIVES="
atrio-archives
consulting-archives
retro-archives
sap-archives
telecom-archives
wse-archives
"

MAX_DIR="1,${1:-90}"
SCRIPTNAME="$(basename $0)"

if $(lsb_release -r > /dev/null 2>&1); then
    UBUNTU_VERSION=$(lsb_release -rs)
    if [ "x${UBUNTU_VERSION}" == 'x8.04' ]; then
        renice 19 $$ > /dev/null
    else
        renice -n 19 -p $$ > /dev/null
    fi
fi

ionice -c3 -p $$

echo "$(date '+%F %T') ${SCRIPTNAME}: Starting"

for DIR in ${DIR_ARCHIVES}; do
    TARGET=${VS_PATH}/${DIR}
    if [ -d ${TARGET} ]; then
        for FOLDER in $(ls -1 ${TARGET} | sort -rn | sed ${MAX_DIR}d); do
            echo "$(date '+%F %T') ${SCRIPTNAME}: remove ${TARGET}/${FOLDER}"
            rm -rf ${TARGET}/${FOLDER}
            sleep 1
        done
    fi
done

echo "$(date '+%F %T') ${SCRIPTNAME}: Finished"

# EOF
