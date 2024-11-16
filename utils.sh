check_error() {
    local error=$1
    local mensaje=$2
    if [ "$error" -ne 0 ]; then
        echo "Error: $mensaje" >&2
        echo 0
    fi
    echo 1

}
