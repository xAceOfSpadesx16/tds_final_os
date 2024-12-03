#!/bin/bash

# Descripción:
# Este script realiza las siguientes acciones:
# 1. Modifica la referencia al archivo de configuración en `scripts/users.sh`.
# 2. Mueve el archivo `users.sh` a un nuevo directorio con un nuevo nombre (`trebol_user.sh`).
# 3. Asigna permisos de ejecución al archivo `trebol_user.sh`.
# 4. Crea un archivo de alias si no existe y agrega un alias para ejecutar el script.
# 5. Proporciona instrucciones al usuario para utilizar el alias configurado.

# Comandos Utilizados:
# - source: Carga las variables y configuraciones definidas en un archivo.
#           Esto permite utilizar los valores del archivo `trebol.conf` en el script.
# - sed: Edita texto en archivos:
#     -i: Edita el archivo directamente.
#     s|...|...|: Reemplaza el contenido entre el delimitador `|` con un nuevo valor.
#         En este caso, reemplaza la línea `source` en `scripts/users.sh`.
# - mv: Mueve o renombra archivos.
#     -f: Fuerza la operación, sobrescribiendo archivos existentes si es necesario.
# - chmod: Cambia los permisos de un archivo o directorio.
#     +x: Agrega permisos de ejecución al archivo, permitiendo que sea ejecutado como un programa.
# - touch: Crea un archivo vacío si no existe. Se utiliza para asegurarse de que el archivo de alias exista.
# - sudo tee:
#     -a: Agrega el contenido al final de un archivo existente sin sobrescribir su contenido.
# - test (`[ ]`): Verifica condiciones. En este caso, se utiliza para comprobar:
#     - Si un archivo existe y es un archivo regular (`[ ! -f ... ]`).
# - exit: Termina la ejecución del script con un código de estado. Un código distinto de 0 indica un error.

source trebol.conf

echo "Modificando la línea 'source' en 'scripts/users.sh'..."
sed -i "s|^source.*|source \"$CONF_ALIAS_PATH\"|" "scripts/users.sh" || {
    echo "Error al modificar el archivo 'users.sh'."
    exit 1
}

echo "Moviendo archivo 'users.sh' a '$SCRIPT_ALIAS_DIR/trebol_user.sh'..."
sudo mv -f "scripts/users.sh" "$SCRIPT_ALIAS_DIR/trebol_user.sh"

if [ $? -eq 0 ]; then
    echo "Archivo 'users.sh' movido exitosamente a '$SCRIPT_ALIAS_DIR/trebol_user.sh'."
else
    echo "Error al mover el archivo 'users.sh'."
    exit 1
fi

sudo chmod +x "$SCRIPT_ALIAS_DIR/trebol_user.sh" || {
    echo "Error al dar permisos de ejecución al archivo trebol_user.sh."
    exit 1
}

if [ ! -f "$ALIAS_FILE" ]; then
    touch "$ALIAS_FILE" || {
        echo "Error al crear el archivo $ALIAS_FILE."
        exit 1
    }
fi

# Agregar alias al archivo de configuración
echo "alias addsambauser='sudo $SCRIPT_ALIAS_DIR/trebol_user.sh'" | sudo tee -a "$ALIAS_FILE" >/dev/null || {
    echo "Error al agregar el alias al archivo $ALIAS_FILE."
    exit 1
}

if [ $? -eq 0 ]; then
    echo "Script y alias creados exitosamente."
    echo "Para crear un nuevo usuario del dominio, ejecute el 'addsambauser'."
else
    echo "Error al crear el script y/o el alias."
    exit 1
fi
