#!/bin/bash


#echo -e "GET / \n\n" | openssl s_client -cipher `openssl ciphers` -tlsextdebug -connect localhost:8443 -state
BOGUS_HTTP_REQ="echo -e \"GET / \n\n\""


if [ -z "$1" ]; then
    echo "No connection string passed. Use: dns.name.tls:443" 1>&2
    exit 1
else
    CONNECT_STRING="$1"
fi


echo "Connecting to: ${CONNECT_STRING}"

$BOGUS_HTTP_REQ | \
    openssl s_client \
    -cipher `openssl ciphers` \
    -tlsextdebug \
    -showcerts \
    -state \
    -connect $CONNECT_STRING


RC=$?


exit ${RC}

