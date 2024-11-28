#!/bin/bash
source trebol.conf
source particiones/part_utils.sh

# //////////////////////////////////////////
# Montaje de las particiones
# //////////////////////////////////////////

agregar_a_fstab() {
    # Agrega los puntos de montaje definidos al archivo fstab.
    # Utiliza obtener_directorios_a_montar para obtener directorios y tamaños.

    local DIRS_MONTAJE=($(obtener_directorios_a_montar))
    local part_number=5

    echo "Agregando puntos de montaje al archivo fstab..." >&2

    for entry in "${DIRS_MONTAJE[@]}"; do
        IFS=":" read -r dir _ <<<"$entry"
        local part="${DISCO}${part_number}"

        # Verifica si ya existe la entrada en fstab
        if ! grep -q "^$part " /etc/fstab; then
            echo "Agregando $part -> $dir en fstab..." >&2
            echo "$part $dir ext4 $OPCIONES_MONTAJE $CHEQUEO_DUMP $CHEQUEO_ORDEN" | sudo tee -a /etc/fstab >/dev/null
        else
            echo "La entrada para $part ya existe en fstab, omitiendo..." >&2
        fi

        part_number=$(($part_number + 1))
    done
}

montaje_particiones() {
    # Agregar al fstab
    agregar_a_fstab

    # Recargar systemd para reconocer cambios en fstab
    echo "Recargando systemd daemon..." >&2
    sudo systemctl daemon-reload

    # Montar todas las particiones
    echo "Montando particiones..." >&2
    sudo mount -a
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    montaje_particiones
fi
