#!/bin/bash
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
