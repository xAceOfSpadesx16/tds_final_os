#!/bin/bash
source trebol.conf
source particiones/part_utils.sh

# //////////////////////////////////////////
# Montaje de las particiones
# //////////////////////////////////////////

agregar_a_fstab() {
    # Descripción:
    #     Esta función agrega los puntos de montaje definidos al archivo `fstab`, utilizando la salida de la función `obtener_directorios_a_montar`
    #     para obtener los directorios y tamaños a montar.
    #     Si la entrada para una partición no existe en el archivo, la agrega con los parámetros definidos.
    #
    # Comandos Utilizados:
    #     grep: busca coincidencias en las líneas de salida.
    #         opciones:
    #             - -q: modo silencioso, no muestra salida.
    #     echo: imprime un texto en la salida estándar.
    #     sudo tee: escribe en un archivo con permisos elevados.
    #         opciones:
    #             - -a: agrega al final del archivo en lugar de sobrescribirlo.
    #     IFS (Internal Field Separator): define el delimitador utilizado para separar los valores.
    #     read: lee la entrada dividida en variables.
    #         opciones:
    #             - -r: evita que los caracteres de escape sean interpretados (como `\`).

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
    # Descripción:
    #     Esta función agrega las particiones al archivo `fstab` mediante la función `agregar_a_fstab`,
    #     recarga el daemon de systemd para reconocer los cambios en `fstab` y monta todas las particiones alli definidas.
    #
    # Comandos Utilizados:
    #     agregar_a_fstab: agrega los puntos de montaje al archivo `fstab` (función previamente definida).
    #     sudo systemctl daemon-reload: recarga el daemon de systemd para aplicar cambios en la configuración.
    #         opciones:
    #             - daemon-reload: recarga la configuración de todos los servicios gestionados por systemd.
    #     sudo mount: monta los sistemas de archivos según la configuración definida en `fstab`.
    #         opciones:
    #             - -a: monta todos los sistemas de archivos listados en `fstab`.
    #

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
