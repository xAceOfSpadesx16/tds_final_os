#!/bin/bash
source trebol.conf
source particiones/part_utils.sh

# //////////////////////////////////////////
# Formateo de las particiones
# //////////////////////////////////////////

crear_tabla_particiones() {
    # Descripción:
    #     Esta función cambia la tabla de particiones del disco especificado a un formato MSDOS, lo cual es necesario
    #     para crear particiones extendidas. Utiliza la herramienta `parted` para realizar la modificación de la tabla
    #     de particiones.
    #
    # Comandos Utilizados:
    #     sudo parted: herramienta para gestionar particiones en discos.
    #         subcomandos:
    #             - mklabel: crea o cambia la etiqueta de la tabla de particiones.
    #         opciones:
    #             - msdos: especifica que la tabla de particiones será de tipo MSDOS, que es compatible con particiones extendidas.
    #
    echo "Creando tabla de particiones MSDOS en $DISCO..." >&2
    sudo parted -s $DISCO mklabel msdos
}

crear_particion_extendida() {
    # Descripción:
    #     Esta función crea una partición extendida que abarca el 100% del disco especificado. Utiliza la herramienta
    #     `parted` para crearla, la cual permite crear particiones lógicas dentro de ella.
    #     No limitando la cantidad de particiones lógicas que se pueden crear.
    #
    # Comandos Utilizados:
    #     sudo parted: herramienta para gestionar particiones en discos.
    #         subcomandos:
    #             - mkpart: crea una nueva partición en el disco.
    #         opciones:
    #             - -s: ejecuta el comando en modo silencioso (sin preguntar).
    #             - extended: especifica que la partición debe ser de tipo extendida.
    #             - 0% 100%: define el inicio de la partición al 0% del disco y el final al 100%.

    echo "Creando partición extendida en todo el disco $DISCO..." >&2
    sudo parted -s $DISCO mkpart extended 0% 100%
}

crear_particiones_logicas() {
    # Descripción:
    #     Esta función crea particiones lógicas dentro de una partición extendida. Utiliza la salida de la función
    #     `obtener_directorios_a_montar` para obtener los directorios y tamaños, y luego crea particiones lógicas
    #     en el disco especificado con los tamaños definidos.
    #
    # Comandos Utilizados:
    #     sudo parted: herramienta para gestionar particiones en discos.
    #         subcomandos:
    #             - mkpart: crea una nueva partición en el disco.
    #         opciones:
    #             - -s: ejecuta el comando en modo silencioso (sin preguntar).
    #             - logical: indica que la partición debe ser lógica.
    #

    echo "Creando particiones lógicas en $DISCO..." >&2

    # Obtener directorios y tamaños
    local DIRS_MONTAJE=($(obtener_directorios_a_montar))

    local INICIO=0
    for entry in "${DIRS_MONTAJE[@]}"; do
        IFS=":" read -r _ size <<<"$entry"
        local FIN=$(($INICIO + size))
        echo "Creando partición lógica de ${size}GB (${INICIO}GB - ${FIN}GB)..." >&2
        sudo parted -s $DISCO mkpart logical ${INICIO}GB ${FIN}GB
        INICIO=$(($FIN))
    done
}

formatear_particiones() {
    # Descripción:
    #     Esta función formatea las particiones lógicas del disco con el sistema de archivos `ext4`.
    #     Utiliza los directorios y tamaños obtenidos a través de la función `obtener_directorios_a_montar` para definir
    #     las particiones que se deben formatear.
    #
    # Comandos Utilizados:
    #     sudo mkfs.ext4: formatea una partición con el sistema de archivos `ext4`.

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
