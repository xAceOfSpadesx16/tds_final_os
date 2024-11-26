#!/bin/bash
source users/user_func.sh
source definicion/directorios.sh
source trebol.conf

procesar_usuarios() {
    for user in $(cat "$DIR_LISTS_PATH/$MAIN_GRP.list"); do
        if crear_usuario_samba "$user"; then
            agregar_a_grp_por_listados "$DIR_LISTS_PATH" "$user"
            crear_home_dir "$user"
        fi
        echo
    done
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    procesar_usuarios
fi
