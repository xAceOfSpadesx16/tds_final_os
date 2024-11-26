#!/bin/bash

source trebol.conf
source utils.sh
obtener_grupos_no_principales() {
    # Variables .conf:
    #     DIR_LISTS_PATH: Directorio donde se encuentran los listados.
    #     MAIN_GRP: Grupo Principal se excluirá del listado.
    #     ADM_GRP: Grupo de Administradores se excluirá del listado.
    #
    # Comandos Utilizados:
    #     ls: lista archivos en el directorio especificado.
    #         opciones:
    #             - 2>/dev/null: suprime los errores si no existen archivos .list.
    #     grep: filtra el listado de archivos.
    #         opciones:
    #             - -v: excluye las líneas que contienen el nombre del grupo principal.
    #             -E: utiliza el patrón regular especificado.
    #     xargs: transforma los nombres de archivo en una lista manejable.
    #         opciones:
    #             - -n 1: asegura que basename procese un archivo a la vez.
    #     basename: elimina la ruta y la extensión .list de cada archivo.
    #         opciones:
    #             - -s, --suffix: elimina la extensión especificada (.list en este caso) de cada nombre de archivo.
    #
    # Salida:
    #     Devuelve un array de nombres de archivos en el directorio DIR_LISTS_PATH que terminan en .list,
    #     excluyendo los archivos coincidentes con MAIN_GRP y con ADM_GRP.

    local nombres=($(ls "$DIR_LISTS_PATH"/*.list 2>/dev/null | grep -vE "/($MAIN_GRP|$ADM_GRP).list" | xargs -n 1 basename -s .list))
    echo "${nombres[@]}"
}

crear_conf_dirs() {
    # Variables .conf:
    #     CREATE_DIRS: Array de directorios a crear con permisos, propietarios y grupos.
    #
    # Comandos Utilizados:
    #     mkdir: crea directorios.
    #         opciones:
    #             -p: crea los directorios padres si no existen.
    echo "Creando directorios definidos en trebol.conf." >&2
    for dir_info in "${CREATE_DIRS[@]}"; do
        IFS=":" read -r path permisos propietario grupo <<<"$dir_info"

        echo "Creando directorio $path" >&2
        sudo mkdir -p "$path"

        check_error $? "Error al crear el directorio $path"

    done
}

crear_grp_dirs() {
    # Variables .conf:
    #     DIR_ROOT_PATH: Directorio raiz de los grupos.
    #
    # Comandos Utilizados:
    #     mkdir: crea directorios.
    #         opciones:
    #             -p: crea los directorios padres si no existen.

    local grupos=($(obtener_grupos_no_principales))
    echo "Creando directorios de grupos."
    for grp in "${grupos[@]}"; do

        echo "Creando directorio $DIR_ROOT_PATH/$grp"
        sudo mkdir -p "$DIR_ROOT_PATH/$grp"
        check_error $? "Error al crear el directorio $DIR_ROOT_PATH/$grp"

    done
}

crear_home_dir() {
    username=$1
    echo "Creando directorio Home de $username..."

    sudo mkdir -m 2700 -p "$DIR_HOME_PATH/$username"
    check_error $? "Error al crear el directorio $DIR_HOME_PATH/$username"
    sudo chown $username:$SYSTEM_ADMIN_USER "$DIR_HOME_PATH/$username"
    check_error $? "Error al asignar propietario al directorio $DIR_HOME_PATH/$username"
    sudo cp -rf "$USE_SKEL/*" "$DIR_HOME_PATH/$username"
    check_error $? "Error al copiar skel al directorio $DIR_HOME_PATH/$username"
}
