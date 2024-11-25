#!/bin/bash
source trebol.conf
source utils.sh
generar_password_random() {
    # Comandos Utilizados:
    #     tr: realiza una traducción o eliminación de caracteres en una entrada. (filtrado)
    #     opciones:
    #         -d, --delete: elimina los caracteres que no esten especificados.
    #         -c, --complement: utiliza el conjunto de caracteres complementario (excluyendo el conjunto especificado).
    #     /dev/urandom: genera una secuencia de datos aleatorios.
    #     head: muestra las primeras líneas de un archivo o secuencia de entrada.
    #     opciones:
    #         -c, --bytes: limita la salida a un número específico de bytes.

    tr -dc 'A-Za-z0-9' </dev/urandom | head -c 8
}

crear_usuario_linux() {
    # Parametros:
    #     1) username
    # Comandos Utilizados:
    #     useradd: crea un nuevo usuario.
    #     opciones:
    #         -d, --home: especifica el path del directorio home del nuevo usuario.
    #         -m, --create-home: crea el directorio home del usuario.
    #         -U, --user-group: crea un grupo con el mismo nombre del usuario.
    #         -s, --shell: especifica el shell del usuario.
    #         -k, --skel: especifica un directorio de plantilla para el home del usuario.
    #    chpasswd: permite al administrador del sistema cambiar contraseñas de usuarios por lotes.

    # local username=$1
    # local password=$(generar_password_random)
    # echo "Creando usuario $username." >&2
    # sudo samba-tool user create "$username" "$password" --home-directory "$DIR_HOME_PATH/$username"

    # error=$(check_error $? "Error al crear el usuario $username en el sistema.")

    # if [[ $error -eq 1 ]]; then
    #     echo -e "Usuario: $username - Contraseña: $password\n" >>"$DIR_ETC_PATH/demo_linux_users.txt"
    # fi

    #registra los usuarios y contraseñas del sistema para fines didacticos
}

crear_usuario_samba() {
    # Parámetros:
    #     1) username
    # Comandos Utilizados:
    #     smbpasswd: administra contraseñas para usuarios Samba.
    #     opciones:
    #         -a: agrega un nuevo usuario a la base de datos de Samba.

    local username=$1
    local manual=$2
    local password=$(generar_password_random)
    sudo samba-tool user create "$username" "$password" --home-directory "$DIR_HOME_PATH/$username"

    error=$(check_error $? "Error al crear el usuario $username en la BBDD de Samba.")

    if [[ $error -eq 1 ]]; then
        echo -e "Usuario: $username - Contraseña: $password\n" >>"$DIR_ETC_PATH/demo_samba_users.txt"
        if [[ $manual ]]; then
            echo "La contraseña asignada para su usuario es: $password" >&2
        fi

    fi

}

agregar_a_grp() {
    local group=$1
    local username=$2

    if [[ -z "$group" || -z "$username" ]]; then
        echo "Error: grupo o usuario no especificados." >&2
        return 1
    fi

    echo "Agregando $username al grupo $group." >&2
    samba-tool group addmembers "$group" "$username"
    check_error $? "Error al agregar $username al grupo $group"
}

agregar_a_grp_por_listados() {
    local dir_path="$1"
    local username="$2"

    if [[ ! -d "$dir_path" ]]; then
        echo "Error: el directorio $dir_path no existe o no es válido." >&2
        return 1
    fi

    for file in "$dir_path"/*.list; do
        if [[ -f "$file" ]]; then
            local group_name=$(basename "$file" .list)

            if grep -q "^$username$" "$file"; then
                if ! samba-tool group list | grep -qw "$group_name"; then
                    echo "Creando grupo $group_name en el servidor." >&2
                    samba-tool group add "$group_name"
                    check_error $? "Error al crear el grupo $group_name en el servidor."
                fi

                agregar_a_grp "$group_name" "$username"
            fi
        fi
    done
}

agregar_user_a_sector() {
    # Parámetros:
    #     1) username: nombre del usuario a agregar al sector.
    #     2) sector: nombre del sector al que se agregará el usuario.
    #
    # Comandos Utilizados:
    #     echo: escribe el nombre del usuario al archivo de lista correspondiente al sector.
    #         opciones:
    #             - >>: redirige la salida de echo al archivo especificado, agregando el texto al final del archivo.
    #
    # Salida:
    #     No produce salida estándar.
    #     El usuario se agrega al archivo correspondiente a su sector; si el archivo no existe, se crea.

    local username=$1
    local sector=$2
    echo "Agregando $username al listado $sector.list" >&2
    echo "$username" >>"$DIR_LISTS_PATH/$sector.list"

}
