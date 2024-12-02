#!/bin/bash
source "$CONF_ALIAS_PATH"

check_error() {
    local error=$1
    local mensaje=$2

    if [ "$error" -ne 0 ]; then
        echo "Error: $mensaje" >&2
        return 1
    fi

    return 0
}

sector_list() {
    local nombres=($(ls "$DIR_LISTS_PATH"/*.list 2>/dev/null | grep -v "/$MAIN_GRP.list" | xargs -n 1 basename -s .list))
    echo "${nombres[@]}"
}

elegir_sector() {
    local sectores_disponibles=("$@")
    local indice_elegido
    local sector

    echo "Sectores disponibles:" >&2
    for ((i = 1; i <= ${#sectores_disponibles[@]}; i++)); do
        echo "$i) ${sectores_disponibles[i - 1]}" >&2
        echo >&2
    done
    while true; do
        read -p "Ingrese el número del sector que le fue asignado: " indice_elegido

        if [[ "$indice_elegido" =~ ^[0-9]+$ ]]; then
            if ((indice_elegido >= 1 && indice_elegido <= ${#sectores_disponibles[@]})); then
                sector="${sectores_disponibles[$((indice_elegido - 1))]}"
                echo "$sector"
                return
            else
                echo "Opción fuera de rango. Por favor, ingrese un número entre 1 y ${#sectores_disponibles[@]}." >&2
                echo >&2
            fi
        else
            echo "Entrada no válida. Por favor, ingrese un número." >&2
            echo >&2
        fi
    done
}

generar_password_random() {
    tr -dc 'A-Za-z0-9' </dev/urandom | fold -w 8 | grep -P '(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9])^.{8}$' | head -n 1
}

crear_usuario_samba() {
    local username=$1
    local manual=$2
    local password=$(generar_password_random)
    sudo samba-tool user create "$username" "$password" >/dev/null

    error=$(check_error $? "Error al crear el usuario $username en la BBDD de Samba.")

    if [[ $error -eq 0 ]]; then
        echo "Usuario $username fue creado con exito en la BBDD de Samba." >&2
        echo -e "Usuario: $username - Contraseña: $password\n" >>"$DIR_ETC_PATH/demo_samba_users.txt"
        if [[ $manual ]]; then
            echo "La contraseña asignada para su usuario es: $password" >&2
        fi

    else
        echo "Error al crear el usuario $username en la BBDD de Samba." >&2
        return 1

    fi

}

crear_directorio_home() {
    local username=$1
    echo "Creando directorio Home de $username..."
    sudo mkdir -m 2750 -p "$DIR_HOME_PATH/$username"
    check_error $? "Error al crear el directorio $DIR_HOME_PATH/$username"
}

asignar_propietario_home() {
    local username=$1
    echo "Asignando propietario inicial al directorio Home de $username..."
    sudo chown "$username:$SYSTEM_ADMIN_USER" "$DIR_HOME_PATH/$username"
    check_error $? "Error al asignar propietario al directorio $DIR_HOME_PATH/$username"
}

copiar_skel_a_home() {
    local username=$1
    echo "Copiando skel al directorio Home de $username..."
    sudo cp -rf "$USE_SKEL/"* "$DIR_HOME_PATH/$username"
    check_error $? "Error al copiar skel al directorio $DIR_HOME_PATH/$username"
}

ajustar_permisos_y_propietarios_home() {
    local username=$1
    echo "Ajustando permisos y propietarios de los archivos y directorios del directorio Home..."
    sudo find "$DIR_HOME_PATH/$username" -type f -exec chmod 640 {} + -exec chown "$username:$SYSTEM_ADMIN_USER" {} +
    sudo find "$DIR_HOME_PATH/$username" -type d -exec chmod 2750 {} + -exec chown "$username:$SYSTEM_ADMIN_USER" {} +
    check_error $? "Error al ajustar permisos o propietarios en $DIR_HOME_PATH/$username"
}

crear_home_dir() {
    local username=$1
    crear_directorio_home "$username"
    asignar_propietario_home "$username"
    copiar_skel_a_home "$username"
    ajustar_permisos_y_propietarios_home "$username"
    sudo samba-tool user sethome "$username" "$DIR_HOME_PATH/$username" >/dev/null
    echo "Directorio Home de $username creado y configurado correctamente."
}

agregar_user_a_sector() {
    local username=$1
    local sector=$2
    echo "Agregando $username al listado $sector.list" >&2
    echo "$username" >>"$DIR_LISTS_PATH/$sector.list"
    check_error $? "Error al agregar $username al listado $sector.list"

}

agregar_a_grp() {
    local group=$1
    local username=$2

    if [[ -z "$group" || -z "$username" ]]; then
        echo "Error: grupo o usuario no especificados." >&2
        return 1
    fi

    if ! samba-tool group list | grep -qw "$group"; then
        echo "Error: El grupo $group no existe en Samba." >&2
        echo "Luego de crearlo, agregue $username al grupo mediante el comando:" >&2
        echo "sudo samba-tool group addmembers <grupo> $username"
        echo "Para ver la lista de grupos existentes, ejecute:" >&2
        echo "sudo samba-tool group list"
        return 1
    fi

    echo "Agregando $username al grupo $group." >&2
    sudo samba-tool group addmembers "$group" "$username" >/dev/null
    check_error $? "Error al agregar $username al grupo $group"
}

main() {
    local sectores_disponibles=($(sector_list))

    if [[ ${#sectores_disponibles[@]} -eq 0 ]]; then
        echo "Error: No hay sectores disponibles." >&2
        exit 1
    fi

    local user
    read -p "Defina un nombre de Usuario: " user

    sector=$(elegir_sector "${sectores_disponibles[@]}")

    echo "Creando usuario $user en samba..."
    crear_usuario_samba "$user" 1

    echo "Creando home de $user..."
    crear_home_dir "$user"

    agregar_user_a_sector "$user" "$MAIN_GRP"

    agregar_user_a_sector "$user" "$sector"

    agregar_a_grp "$MAIN_GRP" "$user"

    agregar_a_grp "$sector" "$user"

}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
