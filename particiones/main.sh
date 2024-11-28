#!/bin/bash

source particiones/part_func.sh

main() {
    crear_tabla_particiones
    crear_particion_extendida
    crear_particiones_logicas
    formatear_particiones
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
