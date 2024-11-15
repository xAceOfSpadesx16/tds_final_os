#!/bin/bash

source trebol.conf
source definicion/directorios.sh

definir_owner_perms_conf_dirs() {
    # Variables .conf:
    #     CREATE_DIRS: Array de directorios a crear con permisos, propietarios y grupos.
    #
    # IFS: separador de campos en la variable CREATE_DIRS por ":"
    #     read: lee una línea de la variable CREATE_DIRS y define las variables.
    #         opciones:
    #             -r: no interpreta los backslashes como escapes
    #
    # Comandos Utilizados:
    #     chmod: cambia los permisos de un archivo o directorio.
    #     chown: cambia el propietario y el grupo de un archivo o directorio.

    for dir_info in "${CREATE_DIRS[@]}"; do
        IFS=":" read -r path permisos propietario grupo <<<"$dir_info"

        # Asignar permisos
        sudo chmod "$permisos" "$path"

        # Asignar propietario y grupo
        sudo chown "$propietario:$grupo" "$path"
    done
}

definir_owner_perms_grp_dirs() {
    # Variables .conf:
    #     DIR_ROOT_PATH: Directorio raiz de los grupos.
    #
    # Comandos Utilizados:
    #     chmod: cambia los permisos de un archivo o directorio.
    #     chown: cambia el propietario y el grupo de un archivo o directorio.

    local grupos=$(obtener_grupos_no_principales)
    for grp in "${grupos[@]}"; do

        # Asignar permisos
        sudo chmod $SECTOR_DIR_PERMS "$DIR_ROOT_PATH/$grp"

        # Asignar propietario y grupo
        sudo chown $SECTOR_DIR_OWNER:$grp "$DIR_ROOT_PATH/$grp"

    done
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    definir_owner_perms_conf_dirs
    definir_owner_perms_grp_dirs
fi
