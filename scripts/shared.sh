#!/bin/bash
source "$CONF_ALIAS_PATH"

# Función para validar longitud mínima
input_min_chars() {
    local mensaje=$1
    local chars_min=$2

    while true; do
        read -p "$mensaje" input
        if [[ ${#input} -ge $chars_min ]]; then
            echo "$input"
            return
        else
            echo "Por favor, ingresa al menos $chars_min caracteres."
        fi
    done
}

# Función para elegir entre opciones
input_opciones() {
    local mensaje=$1
    local opciones_string=$2
    local por_defecto=${3:-$(echo $opciones_string | awk '{print \$1}')}

    IFS=' ' read -r -a opciones <<<"$opciones_string"

    local opciones_separadas
    IFS='/' opciones_separadas="${opciones[*]}"

    while true; do
        local prompt="$mensaje ($opciones_separadas) [default:$por_defecto]: "
        read -p "$prompt" input

        if [[ -z $input ]]; then
            echo "$por_defecto"
            return
        elif [[ " ${opciones[@]} " =~ " $input " ]]; then
            echo "$input"
            return
        else
            echo "Entrada no válida." >&2
        fi
    done
}

input_default() {
    local mensaje=$1
    local por_defecto=$2

    while true; do
        local prompt="$mensaje [default: $por_defecto]: "
        read -p "$prompt" input

        if [[ -z $input ]]; then
            echo "$por_defecto"
            return
        else
            echo "$input"
            return
        fi
    done
}

# Creación de recurso compartido de Samba
echo "Creación de recurso compartido de Samba..."
name=$(input_min_chars "Nombre del recurso compartido (mínimo 3 caracteres): " 3)
path=$(input_default "Ruta del directorio" "$OTROS_MNT/$name")
echo "Si eligió el path por defecto, recuerde crear el directorio $OTROS_MNT/$name y aplicar permisos y propietarios correspondientes."
readonly=$(input_opciones "¿Solo lectura?" "yes no" "no")
browseable=$(input_opciones "Navegable (browseable)" "yes no" "no")
valid_users=$(input_default "Usuarios válidos (valid users)" "@$MAIN_GRP")
read -p "Usuarios con permisos de escritura (write list) [opcional]: " write_list
read -p "Usuarios con permisos de lectura (read list) [opcional]: " read_list
create_mask=$(input_default "Máscara de creación (create mask)" "640")
directory_mask=$(input_default "Máscara de directorio (directory mask)" "2750")
read -p "Comentario (opcional): " comment
read -p "Máximo de conexiones (max connections) [opcional]: " max_connections
read -p "IPs permitidas (hosts allow) [opcional]: " hosts_allow
echo

# Escribir configuración en smb.conf
echo "Escribiendo configuración en /etc/samba/smb.conf..."
cat <<EOT | sed '/^[[:space:]]*$/d' | sudo tee -a /etc/samba/smb.conf >/dev/null

[$name]
    ${comment:+comment = $comment}
    path = $path
    read only = $readonly
    browseable = $browseable
    create mask = $create_mask
    directory mask = $directory_mask
    ${valid_users:+valid users = $valid_users}
    ${write_list:+write list = $write_list}
    ${read_list:+read list = $read_list}
    ${max_connections:+max connections = $max_connections}
    ${hosts_allow:+hosts allow = $hosts_allow}
EOT

if [[ $? -ne 0 ]]; then
    echo "Error al escribir la configuración en /etc/samba/smb.conf"
    exit 1
else
    echo "Configuración escrita exitosamente en /etc/samba/smb.conf."
    echo "Reiniciando el servicio Samba Active Directory Domain Controller..."
    sudo systemctl reload samba-ad-dc
    echo "Verifique la configuración de samba ejecutando 'testparm'."
    exit 0
fi
