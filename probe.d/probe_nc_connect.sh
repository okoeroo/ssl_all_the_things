#!/bin/sh

trap mytrap INT
trap mytrap TERM

NC_PID=

function mytrap() {
    kill -15 ${NC_PID}
}

function use_nc() {
    nc -4 -w 0 "$1" "$2" &
    NC_PID=$!
    wait $NC_PID
}

IP=$2
PORT=$3


### Main
if [ "$#" != "3" ]; then
    echo "Error: Expected the IP and Port number here: $@"
    exit 1
fi

echo "use_nc $IP ${PORT}"
use_nc "$IP" "${PORT}"

