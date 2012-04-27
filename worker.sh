#!/bin/bash

IP="192.16.199.166"
PORT="443"


DROP_ROOT="/tmp/drop_root"


function download_it() {
    IP=$1
    PORT=$2
    OUTPUT=$3

    CONNECT_STRING="${IP}:${PORT}"

    bash download_ssl.sh "$CONNECT_STRING" > "${OUTPUT}" 2>&1
}


function download_to_file() {
    OCTET_1=$1
    OCTET_2=$2
    OCTET_3=$3
    OCTET_4=$4
    PORT=$5

    IP="${OCTET_1}.${OCTET_2}.${OCTET_3}.${OCTET_4}"

    if [ ! -d "${DROP_ROOT}" ]; then
        mkdir -p "${DROP_ROOT}"
    fi

    FILE_DROP="${DROP_ROOT}/${IP}:${PORT}.raw"

    download_it "${IP}" "${PORT}" "${FILE_DROP}"
}


download_to_file 192 16 199 166 443
