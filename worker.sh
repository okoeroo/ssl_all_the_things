#!/bin/bash

DROP_ROOT="/tmp/drop_root"
PROBE_DIR="probe.d"

IP="192.16.199.166"


function probe_host() {
    OCTET_1=$1
    OCTET_2=$2
    OCTET_3=$3
    OCTET_4=$4

    IP="${OCTET_1}.${OCTET_2}.${OCTET_3}.${OCTET_4}"

    # Make the directory for the results about this host
    PROBE_DROP_OUTPUT_DIR="${DROP_ROOT}/${OCTET_1}/${OCTET_2}/${OCTET_3}/${OCTET_4}"

    if [ ! -d "${PROBE_DROP_OUTPUT_DIR}" ]; then
        mkdir -p "${PROBE_DROP_OUTPUT_DIR}" || exit 1
    fi

    ### Launch Probes - Extend if there are more here
    probe_HTTPS ${PROBE_DROP_OUTPUT_DIR} ${IP}
}


# Source the probes
for probe_file in `ls ${PROBE_DIR}/`; do
    if [ -f "${PROBE_DIR}/$probe_file" ]; then
        source "${PROBE_DIR}/$probe_file"
    fi
done


probe_host 192 16 199 166
