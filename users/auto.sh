#!/bin/bash
source users/user_func.sh
source trebol.conf

procesar_usuarios() {

    for user in $(cat "$DIR_LISTS_PATH/$MAIN_GRP.list"); do
        # crear_usuario_linux $user
        crear_usuario_samba $user
        agregar_a_grp_por_listados "$DIR_LISTS_PATH" "$user"
    done

}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    procesar_usuarios
fi
