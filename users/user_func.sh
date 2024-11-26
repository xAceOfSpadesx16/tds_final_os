#!/bin/bash
source trebol.conf
source utils.sh
generar_password_random() {
    # Descripción:
    #     Genera una contraseña aleatoria alfanumérica de exactamente 8 caracteres.
    #     Asegura que la contraseña cumpla con los siguientes requisitos:
    #         - Contiene al menos una letra mayúscula.
    #         - Contiene al menos una letra minúscula.
    #         - Contiene al menos un número.
    #
    # Comandos utilizados:
    #     /dev/urandom:
    #         Fuente de datos aleatorios.
    #     tr:
    #         Filtra la entrada, dejando únicamente letras (A-Za-z) y números (0-9).
    #         Opciones:
    #             -d: elimina caracteres no especificados.
    #             -c: utiliza el conjunto complementario.
    #     fold:
    #         Divide la entrada en líneas de un ancho específico.
    #         Opciones:
    #             -w: especifica el número máximo de caracteres por línea.
    #     grep:
    #         Filtra líneas basadas en un patrón (regex).
    #         Opciones:
    #             -P: permite usar expresiones regulares.
    #             '^.{8}$': asegura que la línea tenga exactamente 8 caracteres.
    #     head:
    #         Muestra únicamente la primera línea de la salida.
    #         Opciones:
    #             -n: limita la salida al número especificado de líneas.

    tr -dc 'A-Za-z0-9' </dev/urandom | fold -w 8 | grep -P '(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9])^.{8}$' | head -n 1
}

crear_usuario_samba() {
    local username=$1
    local manual=$2
    local password=$(generar_password_random)
    sudo samba-tool user create "$username" "$password" --home-directory "$DIR_HOME_PATH/$username" >/dev/null

    error=$(check_error $? "Error al crear el usuario $username en la BBDD de Samba.")

    if [[ $error -eq 0 ]]; then
        echo "Usuario $username fue creado con exito Samba." >&2
        echo -e "Usuario: $username - Contraseña: $password\n" >>"$DIR_ETC_PATH/demo_samba_users.txt"
        if [[ $manual ]]; then
            echo "La contraseña asignada para su usuario es: $password" >&2
        fi

    else
        echo "Error al crear el usuario $username en la BBDD de Samba." >&2
        return 1

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

            if grep -q "^$username$" "$file"; then
                local group_name=$(basename "$file" .list)

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
