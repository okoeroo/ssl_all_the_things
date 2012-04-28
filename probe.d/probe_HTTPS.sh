#!/bin/bash

function probe_HTTPS() {
    OUTPUT_DIR=$1
    IP=$2
    PORT=443

    if [ -z "${OUTPUT_DIR}" ]; then
        echo "No output dir specified. Set one" 1>&2
        exit 1
    fi
    if [ -z "${IP}" ]; then
        echo "What where to? Set hostname of IP" 1>&2
        exit 1
    fi

    PROBE_DROP_OUTPUT_RAW="${OUTPUT_DIR}/ssl_port_${PORT}.raw"
    CONNECT_STRING="${IP}:${PORT}"
    BOGUS_HTTP_REQ="echo -e \"GET / \n\n\""

    echo "Connecting to: ${CONNECT_STRING}" > ${PROBE_DROP_OUTPUT_RAW}

    $BOGUS_HTTP_REQ | \
        openssl s_client \
            -cipher `openssl ciphers` \
            -tlsextdebug \
            -showcerts \
            -state \
            -connect "${CONNECT_STRING}" \
        >> ${PROBE_DROP_OUTPUT_RAW} 2>&1
    RC=$?

    echo "Created file: ${PROBE_DROP_OUTPUT_RAW}"

    return $RC
}


### Main
if [ "$#" != "2" ]; then
    echo "Error: Expected the output dir and the IP address here: $@"
    exit 1
fi

PROBE_DROP_OUTPUT_DIR=$1
IP=$2
probe_HTTPS "${PROBE_DROP_OUTPUT_DIR}" "${IP}"
