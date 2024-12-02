#!/bin/bash

source trebol.conf

if [ ! -f "$CONF_ALIAS_PATH" ]; then
    echo "Creando archivo '$CONF_ALIAS_PATH'..."
    sudo touch "$CONF_ALIAS_PATH"
fi

cat <<EOF | sudo tee "$CONF_ALIAS_PATH" >/dev/null

# [PATHS]
DIR_ETC_PATH="$DIR_ETC_PATH"
DIR_HOME_PATH="$DIR_HOME_PATH"
DIR_LISTS_PATH="$DIR_LISTS_PATH"
SCRIPT_ALIAS_DIR="$SCRIPT_ALIAS_DIR"
USE_SKEL="$USE_SKEL"
OTROS_MNT="$OTROS_MNT"

# [USUARIOS]
SYSTEM_ADMIN_USER="$SYSTEM_ADMIN_USER"

# [GRUPOS]
MAIN_GRP="$MAIN_GRP"

EOF

if [ $? -eq 0 ]; then
    echo "Archivo '$CONF_ALIAS_PATH' creado correctamente."
else
    echo "Error al crear el archivo '$CONF_ALIAS_PATH'."
    exit 1
fi
