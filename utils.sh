#!/bin/bash
source trebol.conf

check_error() {
    local error=$1
    local mensaje=$2
    if [ "$error" -ne 0 ]; then
        echo "Error: $mensaje" >&2
        echo 0
        return 0
    fi
    echo 1
    return 1
}

obtener_ip() {
    ip -4 addr show $ADAPTADOR | grep -oP '(?<=inet\s)\d+(\.\d+){3}'
}
