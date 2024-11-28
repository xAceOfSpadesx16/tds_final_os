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

# //////////////////////////////////////////
# Formateo de las particiones
# //////////////////////////////////////////

crear_tabla_particiones() {
    # Cambia la tabla de particiones a MSDOS para soportar particiones extendidas.
    # Variables .conf:
    #     DISCO: Disco a formatear.
    echo "Creando tabla de particiones MSDOS en $DISCO..." >&2
    sudo parted -s $DISCO mklabel msdos
}

crear_particion_extendida() {
    # Crea una partición extendida que abarque el 100% del disco.
    # Variables .conf:
    #     DISCO: Disco a formatear.
    echo "Creando partición extendida en todo el disco $DISCO..." >&2
    sudo parted -s $DISCO mkpart extended 0% 100%
}

crear_particiones_logicas() {
    # Crea particiones lógicas dentro de la partición extendida.
    # Utiliza obtener_directorios_a_montar para obtener los directorios dinámicos y estáticos.
    # Variables:
    #     DISCO: Disco a formatear.

    echo "Creando particiones lógicas en $DISCO..." >&2

    # Obtener directorios y tamaños
    local DIRS_MONTAJE=($(obtener_directorios_a_montar))

    local INICIO=0
    for entry in "${DIRS_MONTAJE[@]}"; do
        IFS=":" read -r _ size <<<"$entry"
        local FIN=$(($INICIO + size - 1))
        echo "Creando partición lógica de ${size}GB (${INICIO}GB - ${FIN}GB)..." >&2
        sudo parted -s $DISCO mkpart logical ${INICIO}GB ${FIN}GB
        INICIO=$(($FIN + 1))
    done
}

formatear_particiones() {
    # Formatea las particiones lógicas creadas con el sistema de archivos ext4.
    # Variables:
    #     DISCO: Disco a formatear.
    #     directorios_y_tamanos: Array con directorios y tamaños en formato "directorio:tamaño".
    echo "Formateando particiones lógicas en $DISCO..." >&2
    # Particiones lógicas comienzan en sdx5.
    local part_number=5
    local DIRS_MONTAJE=($(obtener_directorios_a_montar))

    for entry in "${DIRS_MONTAJE[@]}"; do
        echo "Formateando ${DISCO}${part_number} como ext4..." >&2
        sudo mkfs.ext4 ${DISCO}${part_number} >/dev/null 2>&1
        part_number=$(($part_number + 1))
    done
}
