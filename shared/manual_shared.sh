#!/bin/bash

source trebol.conf

if [ ! -f "$SCRIPT_ALIAS_DIR/trebol_share.sh" ]; then
    echo "Creando archivo '$SCRIPT_ALIAS_DIR/trebol_share.sh'..."
    sudo touch "$SCRIPT_ALIAS_DIR/trebol_share.sh"
fi

cat <<EOF | sudo tee "$SCRIPT_ALIAS_DIR/trebol_share.sh" >/dev/null
#!/bin/bash
source "$CONF_ALIAS_PATH"

# Función para validar longitud mínima
input_min_chars() {
    local mensaje=\$1
    local chars_min=\$2

    while true; do
        read -p "\$mensaje" input
        if [[ \${#input} -ge \$chars_min ]]; then
            echo "\$input"
            return
        else
            echo "Por favor, ingresa al menos \$chars_min caracteres."
        fi
    done
}

# Función para elegir entre opciones
input_opciones() {
    local mensaje=\$1
    local opciones_string=\$2
    local por_defecto=\${3:-\$(echo \$opciones_string | awk '{print \$1}')}

    IFS=' ' read -r -a opciones <<<"\$opciones_string"

    local opciones_separadas
    IFS='/' opciones_separadas="\${opciones[*]}"

    while true; do
        local prompt="\$mensaje (\$opciones_separadas) [default:\$por_defecto]: "
        read -p "\$prompt" input

        if [[ -z \$input ]]; then
            echo "\$por_defecto"
            return
        elif [[ " \${opciones[@]} " =~ " \$input " ]]; then
            echo "\$input"
            return
        else
            echo "Entrada no válida."
        fi
    done
}

input_default() {
    local mensaje=\$1
    local por_defecto=\$2

    while true; do
        local prompt="\$mensaje [default: \$por_defecto]: "
        read -p "\$prompt" input

        if [[ -z \$input ]]; then
            echo "\$por_defecto"
            return
        else
            echo "\$input"
            return
        fi
    done
}

# Creación de recurso compartido de Samba
echo "Creación de recurso compartido de Samba..."
name=\$(input_min_chars "Nombre del recurso compartido (mínimo 3 caracteres): " 3)
path=\$(input_min_chars "Ruta del directorio (mínimo 5 caracteres): " 5)

if [[ ! -d \$path ]]; then
    echo "Error: La ruta especificada no existe o no es válida."
    exit 1
fi

readonly=\$(input_opciones "¿Solo lectura?" "si no" "no")
browseable=\$(input_opciones "Navegable (browseable)" "si no" "no")
valid_users=\$(input_default "Usuarios válidos (valid users)" "@\$MAIN_GRP")
read -p "Usuarios con permisos de escritura (write list) [opcional]: " write_list
read -p "Usuarios con permisos de lectura (read list) [opcional]: " read_list
create_mask=\$(input_default "Máscara de creación (create mask)" "640")
directory_mask=\$(input_default "Máscara de directorio (directory mask)" "2750")
read -p "Comentario (opcional): " comment
read -p "Máximo de conexiones (max connections) [opcional]: " max_connections
read -p "IPs permitidas (hosts allow) [opcional]: " hosts_allow
echo


# Escribir configuración en smb.conf
echo "Escribiendo configuración en /etc/samba/smb.conf..."
cat <<EOT | sudo tee -a /etc/samba/smb.conf >/dev/null

[\$name]
    \${comment:+comment = \$comment}
    path = \$path
    read only = \$readonly
    browseable = \$browseable
    create mask = \$create_mask
    directory mask = \$directory_mask
    \${valid_users:+valid users = \$valid_users}
    \${write_list:+write list = \$write_list}
    \${read_list:+read list = \$read_list}
    \${max_connections:+max connections = \$max_connections}
    \${hosts_allow:+hosts allow = \$hosts_allow}
EOT

if [[ \$? -ne 0 ]]; then
    echo "Error al escribir la configuración en /etc/samba/smb.conf"
    exit 1
else
    echo "Configuración escrita exitosamente en /etc/samba/smb.conf."
    echo "Reiniciando el servicio Samba Active Directory Domain Controller..."
    sudo systemctl reload samba-ad-dc
    echo "Verifique la configuración de samba ejecutando 'testparm'."
    exit 0
fi

EOF

# Establecer permisos de ejecución
sudo chmod +x "$SCRIPT_ALIAS_DIR/trebol_share.sh" || {
    echo "Error al dar permisos de ejecución al archivo trebol_share.sh."
    exit 1
}

if [ ! -f "$ALIAS_FILE" ]; then
    touch "$ALIAS_FILE" || {
        echo "Error al crear el archivo $ALIAS_FILE."
        exit 1
    }
fi

# Agregar alias al archivo de configuración
echo "alias addshared='sudo $SCRIPT_ALIAS_DIR/trebol_share.sh'" | sudo tee -a "$ALIAS_FILE" >/dev/null || {
    echo "Error al agregar el alias al archivo $ALIAS_FILE."
    exit 1
}
if [ $? -eq 0 ]; then
    echo "Script y alias creados exitosamente."
    echo "Para crear un recurso compartido, ejecute el 'addshared'."
else
    echo "Error al crear el script y/o el alias."
    exit 1
fi
