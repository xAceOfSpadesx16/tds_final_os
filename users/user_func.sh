#!/bin/bash
source trebol.conf

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

    tr -dc 'A-Za-z0-9' </dev/urandom | head -c 6
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

    local username=$1
    local password=$(generar_password_random)
    sudo useradd -d "$HOME_PATH/$username" -m -U -s /bin/bash -k $SKEL_DIR $username
    sudo echo $username:$password | sudo chpasswd

    #registra los usuarios y contraseñas del sistema para fines didacticos
    echo -e "Usuario: $username - Contraseña: $password\n" >>"$ETC_PASSWORDS_DIR/demo_linux_users.txt"
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
    local password=$(generar_random_password)
    (
        echo "$password"
        echo "$password"
    ) | sudo smbpasswd -a $username >/dev/null 2>&1

    #registra los usuarios y contraseñas de la BBDD de Samba para fines didacticos
    echo -e "Usuario: $username - Contraseña: $password\n" >>"$ETC_PASSWORDS_DIR/demo_samba_users.txt"

    if [[ $manual ]]; then
        echo "La contraseña asignada para su usuario es: $password" >&2
    fi
}

agregar_a_grp() {
    # Parámetros:
    #     1) group: nombre del grupo al que se agregará el usuario.
    #     2) username: nombre del usuario que se agregará al grupo.
    # Comandos Utilizados:
    #     usermod: modifica los atributos de un usuario del sistema.
    #     opciones:
    #         -aG: agrega al usuario a un grupo sin removerlo de otros grupos.

    local group=$1
    local username=$2
    sudo usermod -aG "$group" "$username"
}

agregar_a_grp_por_listados() {
    # Parámetros:
    #     1) dir_path: ruta del directorio que contiene los archivos con extensión .list.
    #     2) username: nombre del usuario que se agregará a grupos dependiendo del archivo que se encuentre.
    #
    # Comandos Utilizados:
    #
    #     grep: busca líneas en los archivos que coinciden con un patrón.
    #         opciones:
    #             -q: modo silencioso, solo verifica si hay coincidencia.
    #
    #     basename: obtiene solo el nombre del archivo, excluyendo el directorio y la extensión.
    #
    #     getent: busca en las bases de datos del sistema.
    #     opciones:
    #         group: consulta el grupo en la base de datos de grupos.
    #
    #     groupadd: crea un nuevo grupo en el sistema.

    local dir_path="$1"
    local username="$2"

    if [[ ! -d "$dir_path" ]]; then
        return 1
    fi

    for file in "$dir_path"/*.list; do
        local group_name=$(basename "$file" .list)

        if grep -q "^$username$" "$file"; then

            if ! getent group "$group_name" >/dev/null; then
                sudo groupadd "$group_name"
            fi

            agregar_a_grp "$group_name" "$username"
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

    echo "$username" >>"$LISTS_PATH/$sector.list"

}
