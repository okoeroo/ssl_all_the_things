#!/bin/bash

PROBE_DROP_ROOT="${PROBE_DROP_ROOT:-/tmp/drop_root}"
PROBE_DIR="${PROBE_DIR:-probe.d}"
TIMEOUT=1

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

### Probe activitor
function probe_host() {
    OCTET_1=$1
    OCTET_2=$2
    OCTET_3=$3
    OCTET_4=$4

    IP="${OCTET_1}.${OCTET_2}.${OCTET_3}.${OCTET_4}"

    # Make the directory for the results about this host
    PROBE_DROP_OUTPUT_DIR="${PROBE_DROP_ROOT}/${OCTET_1}/${OCTET_2}/${OCTET_3}/${OCTET_4}"

    if [ ! -d "${PROBE_DROP_OUTPUT_DIR}" ]; then
        mkdir -p "${PROBE_DROP_OUTPUT_DIR}" || exit 1
    fi

    ### Launch Probes - Extend if there are more here
    ${PROBE_DIR}/probe_HTTPS.sh "${PROBE_DROP_OUTPUT_DIR}" "${IP}" &

    CHILD=$!
    NOW=`date "+%s"`

    while [ 1 ]; do
        kill -0 $CHILD > /dev/null 2>&1 || break

        # When timeout reached
        CURRENT=`date "+%s"`
        SPEND_TIME=$(($CURRENT-$NOW))

        if [ "${SPEND_TIME}" -gt "$TIMEOUT" ]; then
            echo "Warning: Time out reached"
            kill -9 $CHILD
            break
        fi
    done
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

# Source the probes
#for probe_file in `ls ${PROBE_DIR}/`; do
#    if [ -f "${PROBE_DIR}/$probe_file" ]; then
#        source "${PROBE_DIR}/$probe_file"
#    fi
#done

# Engage !
probe_host $1 $2 $3 $4
