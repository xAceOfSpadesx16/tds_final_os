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

# ///////////////////////////////////////////////////////////////////////////
#
# Funciones de creación de directorios Home
#
# ///////////////////////////////////////////////////////////////////////////

crear_directorio_home() {
    # Crea el directorio home de un usuario con permisos predeterminados.
    # Argumentos:
    #     $1: Nombre del usuario para el cual se creará el directorio home.
    # Comandos Utilizados:
    #     mkdir: crea directorios.
    #         opciones:
    #             -m: establece los permisos iniciales.
    #             -p: crea los directorios padres si no existen.
    local username=$1
    echo "Creando directorio Home de $username..."
    sudo mkdir -m 2750 -p "$DIR_HOME_PATH/$username"
    check_error $? "Error al crear el directorio $DIR_HOME_PATH/$username"
}

asignar_propietario_home() {
    # Asigna el propietario y grupo al directorio home de un usuario.
    # Argumentos:
    #     $1: Nombre del usuario.
    # Comandos Utilizados:
    #     chown: cambia el propietario y grupo de un archivo o directorio.
    local username=$1
    echo "Asignando propietario inicial al directorio Home de $username..."
    sudo chown "$username:$SYSTEM_ADMIN_USER" "$DIR_HOME_PATH/$username"
    check_error $? "Error al asignar propietario al directorio $DIR_HOME_PATH/$username"
}

copiar_skel_a_home() {
    # Copia los archivos del directorio SKEL al directorio home del usuario.
    # Argumentos:
    #     $1: Nombre del usuario.
    # Comandos Utilizados:
    #     cp: copia archivos y directorios.
    #         opciones:
    #             -r: copia recursivamente.
    #             -f: fuerza la copia sobre archivos existentes.
    local username=$1
    echo "Copiando skel al directorio Home de $username..."
    sudo cp -rf "$USE_SKEL/"* "$DIR_HOME_PATH/$username"
    check_error $? "Error al copiar skel al directorio $DIR_HOME_PATH/$username"
}

ajustar_permisos_y_propietarios_home() {
    # Ajusta los permisos y propietarios de los archivos y directorios en un directorio home.
    # Argumentos:
    #     $1: Nombre del usuario.
    # Comandos Utilizados:
    #     find: busca archivos y directorios para aplicar comandos.
    #         opciones:
    #             -type f: selecciona archivos.
    #             -type d: selecciona directorios.
    #             -exec: ejecuta un comando sobre los resultados.
    #     chmod: cambia los permisos.
    #     chown: cambia el propietario y grupo.
    local username=$1
    echo "Ajustando permisos y propietarios de los archivos y directorios del directorio Home..."
    sudo find "$DIR_HOME_PATH/$username" -type f -exec chmod 640 {} + -exec chown "$username:$SYSTEM_ADMIN_USER" {} +
    sudo find "$DIR_HOME_PATH/$username" -type d -exec chmod 2750 {} + -exec chown "$username:$SYSTEM_ADMIN_USER" {} +
    check_error $? "Error al ajustar permisos o propietarios en $DIR_HOME_PATH/$username"
}

# Función principal que encapsula la creación y configuración de un directorio home.

crear_home_dir() {
    # Función principal que encapsula la creación y configuración de un directorio home.
    # Argumentos:
    #     $1: Nombre del usuario.
    local username=$1
    crear_directorio_home "$username"
    asignar_propietario_home "$username"
    copiar_skel_a_home "$username"
    ajustar_permisos_y_propietarios_home "$username"
    echo "Directorio Home de $username creado y configurado correctamente."
}
