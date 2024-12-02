#!/bin/bash

source trebol.conf

echo "Modificando la línea 'source' en 'scripts/shared.sh'..."
sed -i "s|^source.*|source \"$CONF_ALIAS_PATH\"|" "scripts/shared.sh" || {
    echo "Error al modificar el archivo 'shared.sh'."
    exit 1
}

echo "Moviendo archivo 'shared.sh' a '$SCRIPT_ALIAS_DIR/trebol_share.sh'..."
sudo mv -f "scripts/shared.sh" "$SCRIPT_ALIAS_DIR/trebol_share.sh"

if [ $? -eq 0 ]; then
    echo "Archivo 'shared.sh' movido exitosamente a '$SCRIPT_ALIAS_DIR/trebol_share.sh'."
else
    echo "Error al mover el archivo 'shared.sh'."
    exit 1
fi

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
