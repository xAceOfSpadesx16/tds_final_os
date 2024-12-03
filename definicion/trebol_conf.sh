#!/bin/bash

# Descripción:
#     Este script verifica la existencia de un archivo de configuración (`CONF_ALIAS_PATH`) y lo crea si no existe.
#     Posteriormente, escribe en el archivo configuraciones predefinidas tomadas del archivo `trebol.conf`.

#
# Comandos Utilizados:
#     source: carga las variables y configuraciones definidas en un archivo externo.
#     if ([ ! -f ]): evalúa si un archivo no existe en el sistema.
#         opciones:
#             - -f: comprueba si un archivo existe y es un archivo regular.
#     sudo touch: crea un archivo vacío con permisos de superusuario.
#     cat: imprime contenido en la salida estándar o lo pasa a otros comandos.
#         opciones:
#             - <<EOF: define un bloque de texto que se termina al encontrar la marca `EOF`.
#     tee: copia el contenido recibido en un archivo, reemplazándolo.
#     exit: finaliza la ejecución del script con un código de salida.
#         opciones:
#             - [número]: define el código de salida (0 por éxito, 1 por error).

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
