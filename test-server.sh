#!/usr/bin/env bash
# Simple nginx static content as a test server

CONTAINER_NAME="blag-test-server"

function start() {
    docker run --detach --rm --name ${CONTAINER_NAME} \
       --volume $(pwd)/build:/usr/share/nginx/html:ro \
       --publish 8080:80 \
       nginx:latest
}

function stop() {
    docker kill ${CONTAINER_NAME}
}

case ${1} in
    start)
        start
        ;;
    stop)
        stop
        ;;
    *)
        echo "Invalid argument, allowed values are 'start' and 'stop'" 2> /dev/stderr
        exit 1
        ;;
esac
