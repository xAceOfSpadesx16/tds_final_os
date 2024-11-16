#!/bin/bash

source trebol.conf
source definicion/skel.sh
source definicion/directorios.sh
source definicion/listas.sh

main() {
    copiar_a_skel
    crear_conf_dirs
    copiar_listas
    crear_grp_dirs
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
