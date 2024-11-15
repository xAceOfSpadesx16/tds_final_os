#!/bin/bash

source particiones/part_func.sh

main() {
    crear_tabla_particiones
    crear_particiones
    formatear_particiones
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
