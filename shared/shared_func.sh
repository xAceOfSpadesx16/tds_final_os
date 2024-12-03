#!/bin/bash

source utils.sh

check_parm_y_reinicio_servicios() {
    # Descripción:
    #     Esta función verifica la configuración de Samba utilizando `testparm`,
    #     reinicia el servicio Samba Active Directory Domain Controller y
    #     verifica su estado.

    # Comandos utilizados:
    #     - `sudo testparm`:
    #         Verifica la configuración del archivo smb.conf para detectar posibles errores.
    #     - `sudo systemctl restart samba-ad-dc`:
    #         Reinicia el servicio Samba Active Directory Domain Controller.
    #     - `sudo systemctl status samba-ad-dc --no-pager`:
    #         Muestra el estado actual del servicio `samba-ad-dc`.
    #         Opciones:
    #             - `--no-pager`: Desactiva el paginador, mostrando todo el contenido en una sola pantalla.

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

    # Descripción:
    #     Esta función configura un recurso compartido en Samba de forma no interactiva,
    #     añadiendo la configuración al archivo smb.conf para un recurso específico con los
    #     parámetros proporcionados.

    # Comandos utilizados:
    #     - `cat <<EOF | sudo tee -a /etc/samba/smb.conf >/dev/null`:
    #         Utiliza `cat` para crear un bloque de texto y `tee -a` para agregar dicho texto al archivo `/etc/samba/smb.conf`.
    #         Opciones:
    #             - `tee -a`: Añade el contenido al final del archivo sin sobrescribirlo.
    #             - `<<EOF`: Define un bloque de texto que termina cuando se encuentra con `EOF`.
    #     - `/etc/samba/smb.conf`:
    #         Archivo de configuración de Samba donde se definen los recursos compartidos. La entrada generada contiene:
    #         - `[name]`: Nombre del recurso compartido.
    #         - `comment`: Comentario descriptivo del recurso.
    #         - `path`: Ruta donde se encuentra el directorio a compartir.
    #         - `read only`: Indica si el recurso es de solo lectura (`yes` o `no`).
    #         - `browseable`: Define si el recurso es visible en la red.
    #         - `create mask`: Define los permisos predeterminados al crear archivos en el recurso compartido.
    #         - `directory mask`: Define los permisos predeterminados al crear directorios en el recurso.
    #         - `valid users`: Lista de usuarios válidos que pueden acceder al recurso.
    #         - `write list`: Lista de usuarios con permisos de escritura en el recurso.
    #         - `max connections`: Número máximo de conexiones permitidas al recurso.
    #         - `hosts allow`: Define las direcciones IP o rangos de direcciones permitidas para acceder al recurso.

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
    cat <<EOF | sed '/^[[:space:]]*$/d' | sudo tee -a /etc/samba/smb.conf >/dev/null

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
    # Descripción:
    #     Esta función configura el recurso compartido de "homes" en Samba para
    #     los directorios personales de los usuarios. La configuración se agrega
    #     al archivo smb.conf.

    # Comandos utilizados:
    #     - `cat <<EOF | sudo tee -a /etc/samba/smb.conf >/dev/null`:
    #         Añade la configuración para el recurso compartido "homes" al archivo smb.conf.
    #         Opciones:
    #             - `tee -a`: Agrega la entrada al final del archivo `/etc/samba/smb.conf`.
    #             - `>/dev/null`: Redirige la salida estándar para evitar mostrarla en consola.
    #             - `<<EOF`: Define un bloque de texto que se termina cuando se encuentra `EOF`.

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
