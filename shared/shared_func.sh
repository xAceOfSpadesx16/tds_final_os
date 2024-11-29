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

# Función para crear un recurso compartido en smb.conf
creacion_interactiva_recurso_compartido() {
    echo "Creando un recurso compartido de Samba..."

    # Solicitud de parametros
    input_min_chars "Nombre del recurso compartido (mínimo 3 caracteres): " name 3
    input_min_chars "Ruta del directorio (mínimo 5 caracteres): " path 5

    read -p "¿Solo lectura? (yes/no) [default: no]: " readonly
    read -p "¿Navegable (browseable)? (yes/no) [default: no]: " browseable
    read -p "Usuarios válidos (valid users) [%U por defecto]: " valid_users
    read -p "Usuarios con permisos de escritura (write list) [opcional]: " write_list
    read -p "Máscara de creación (create mask) [default: 0700]: " create_mask
    read -p "Máscara de directorio (directory mask) [default: 0700]: " directory_mask
    read -p "Comentario (opcional): " comment
    read -p "Máximo de conexiones (max connections) [opcional]: " max_connections
    read -p "IPs permitidas (hosts allow) [opcional]: " hosts_allow

    # Definición de valores por defecto
    readonly=${readonly:-no}
    browseable=${browseable:-no}
    valid_users=${valid_users:-%U}
    create_mask=${create_mask:-0700}
    directory_mask=${directory_mask:-0700}

    # Creación de recurso compartido
    echo "Escribiendo configuración en /etc/samba/smb.conf..." >&2
    cat <<EOF >>/etc/samba/smb.conf

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

    echo "Recurso compartido '$name' agregado exitosamente." >&2
    echo >&2
    check_parm_y_reinicio_servicios
}

creacion_no_interactiva_recurso_compartido() {
    # Parámetros esperados
    local name="$1"
    local path="$2"
    local readonly="${3:-no}"
    local browseable="${4:-no}"
    local valid_users="${5:-%U}"
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

    echo "Recurso compartido '$name' agregado exitosamente." >&2
    echo >&2
}

crear_shared_home() {
    echo "Configurando el recurso compartido para 'home' de usuarios..." >&2

    # Agregar configuración en smb.conf
    cat <<EOF | sudo tee -a /etc/samba/smb.conf >/dev/null

[homes]
    comment = Directorios personales
    path = $DIR_HOME_PATH
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
