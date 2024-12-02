#!/bin/bash
source trebol.conf

check_error() {
    local error=$1
    local mensaje=$2

    if [ "$error" -ne 0 ]; then
        echo "Error: $mensaje" >&2
        return 1
    fi

    return 0
}

obtener_ip() {
    ip -4 addr show $ADAPTADOR | grep -oP '(?<=inet\s)\d+(\.\d+){3}'
}

obtener_red() {
    ip addr show $ADAPTADOR | awk '/inet / {print $2}' | xargs -I{} ipcalc -n {} | awk '/Network/ {print $2}'
}

input_min_chars() {
    local mensaje=$1
    local variable=$2
    local chars_min=$3

    while true; do
        read -p "$mensaje" input
        if [[ ${#input} -ge $chars_min ]]; then
            eval "$variable='$input'"
            break
        else
            echo "Por favor, ingresa al menos $chars_min caracteres."
        fi
    done
}

input_opciones() {
    local mensaje=$1
    local opciones_string=$2
    local por_defecto=${3:-$(echo $opciones_string | awk '{print $1}')}

    IFS=' ' read -r -a opciones <<<"$opciones_string"

    local opciones_separadas
    IFS='/' opciones_separadas="${opciones[*]}"

    while true; do
        local prompt="$mensaje ($opciones_separadas) [default:$por_defecto]: "
        read -p "$prompt" input

        if [[ -z $input ]]; then
            echo "$por_defecto"
            return
        elif [[ " ${opciones[@]} " =~ " $input " ]]; then
            echo "$input"
            return
        else
            echo "Entrada no válida."
        fi
    done
}
