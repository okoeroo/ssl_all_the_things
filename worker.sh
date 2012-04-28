#!/bin/bash

PROBE_DROP_ROOT="${PROBE_DROP_ROOT:-/tmp/drop_root}"
PROBE_DIR="${PROBE_DIR:-probe.d}"
PROBE_TIMEOUT="${PROBE_TIMEOUT:-10}"

### Helper
function number_is_octet() {
    OCTET=$1

    regex="[0-9]+"
    if [[ "$OCTET" =~ $regex ]]; then
        if [ $OCTET -lt 256 ]; then
            return 0
        fi
    fi
    echo "Error: Input is not an octet for an IP address: $OCTET"
    return 1
}

### Probe activitors
function probe_launcher() {
    PROBE_SCRIPT=$1
    THE_PROBE_TIMEOUT=$2
    PROBE_DROP_OUTPUT_DIR=$3
    IP=$4
    PORT=$5

    ### Launch Probes - Extend if there are more here
    "${PROBE_SCRIPT}" "${PROBE_DROP_OUTPUT_DIR}" "${IP}" $PORT &

    CHILD=$!
    NOW=`date "+%s"`

    while [ 1 ]; do
        kill -0 $CHILD > /dev/null 2>&1 || break

        # When timeout reached
        CURRENT=`date "+%s"`
        SPEND_TIME=$(($CURRENT-$NOW))

        if [ "${SPEND_TIME}" -gt "${THE_PROBE_TIMEOUT}" ]; then
            echo "Warning: Time out reached"
            kill -15 $CHILD
            sleep 1

            # if still there, kill it 4 real
            kill -0 $CHILD > /dev/null 2>&1 && kill -9 $CHILD
            break
        fi
    done
    wait $CHILD >/dev/null 2>&1
    RC=$?
    return $RC
}


function probe_host() {
    OCTET_1=$1
    OCTET_2=$2
    OCTET_3=$3
    OCTET_4=$4

    IP="${OCTET_1}.${OCTET_2}.${OCTET_3}.${OCTET_4}"

    # Add pre-launch probes, like is there a port 443 alive
    probe_launcher "${PROBE_DIR}/probe_nc_connect.sh" "${PROBE_TIMEOUT}" "${PROBE_DROP_OUTPUT_DIR}" "${IP}" "443" || return 1


    # Make the directory for the results about this host
    PROBE_DROP_OUTPUT_DIR="${PROBE_DROP_ROOT}/${OCTET_1}/${OCTET_2}/${OCTET_3}/${OCTET_4}"

    if [ ! -d "${PROBE_DROP_OUTPUT_DIR}" ]; then
        mkdir -p "${PROBE_DROP_OUTPUT_DIR}" || exit 1
    fi


    ### Launch Probes - Extend if there are more here
    probe_launcher "${PROBE_DIR}/probe_HTTPS.sh" "${PROBE_TIMEOUT}" "${PROBE_DROP_OUTPUT_DIR}" "${IP}"
    RC=$?
    return $RC
}


### MAIN
if [ "$#" != "4" ]; then
    echo "Error: provide me an IP address split over the 4 octets, example: $0 127 0 0 1"
    exit 1
else
    number_is_octet $1 || exit 1
    number_is_octet $2 || exit 1
    number_is_octet $3 || exit 1
    number_is_octet $4 || exit 1
fi

# Engage !
probe_host $1 $2 $3 $4
RC=$?

exit $RC

