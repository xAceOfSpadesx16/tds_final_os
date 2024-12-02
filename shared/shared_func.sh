#!/bin/bash

source utils.sh

check_parm_y_reinicio_servicios() {
    echo "Chequeando que la configuración sea correcta..." >&2
    sudo testparm
    echo "Reiniciando el servicio Samba Active Directory Domain Controller..." >&2
    sudo systemctl restart samba-ad-dc
    echo >&2
    sleep 2
    echo "Verificando el estado del servicio..." >&2
    sudo systemctl status samba-ad-dc --no-pager
}

creacion_no_interactiva_recurso_compartido() {
    # Parámetros esperados
    local name="$1"
    local path="$2"
    local readonly="${3:-no}"
    local browseable="${4:-no}"
    local valid_users="${5:-"@$MAIN_GRP"}"
    local write_list="${6:-}"
    local create_mask="${7:-640}"
    local directory_mask="${8:-2750}"
    local comment="${9:-}"
    local max_connections="${10:-}"
    local hosts_allow="${11:-}"

    # Validación mínima de parámetros
    if [[ -z "$name" || -z "$path" ]]; then
        echo "Error: 'name' y 'path' son obligatorios."
        echo "Uso: creacion_no_interactiva_recurso_compartido <name> <path> [readonly] [browseable] [valid_users] [write_list] [create_mask] [directory_mask] [comment] [max_connections] [hosts_allow]"
        return 1
    fi

    # Creación de recurso compartido
    echo "Escribiendo configuración en /etc/samba/smb.conf..." >&2
    cat <<EOF | sudo tee -a /etc/samba/smb.conf >/dev/null

[$name]
    ${comment:+comment = $comment}
    path = $path
    read only = $readonly
    browseable = $browseable
    create mask = $create_mask
    directory mask = $directory_mask
    ${valid_users:+valid users = $valid_users}
    ${write_list:+write list = $write_list}
    ${max_connections:+max connections = $max_connections}
    ${hosts_allow:+hosts allow = $hosts_allow}
EOF
    if [ $? -ne 0 ]; then
        echo "Error al escribir la configuración en /etc/samba/smb.conf." >&2
        return 1
    else
        echo "Recurso compartido '$name' agregado exitosamente." >&2
        echo >&2

    fi
}

crear_shared_home() {
    echo "Configurando el recurso compartido para 'home' de usuarios..." >&2

    # Agregar configuración en smb.conf
    cat <<EOF | sudo tee -a /etc/samba/smb.conf >/dev/null

[homes]
    comment = Directorios personales
    path = $DIR_HOME_PATH/%S
    browseable = no
    read only = no

    valid users = %S
    create mask = 640
    directory mask = 2750
EOF

    echo "Recurso compartido 'homes' configurado exitosamente." >&2
    echo >&2
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    creacion_interactiva_recurso_compartido
fi
