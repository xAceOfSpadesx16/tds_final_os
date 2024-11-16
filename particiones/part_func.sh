#!/bin/bash
source trebol.conf

crear_tabla_particiones() {
    # Variables .conf:
    #     DISCO: Disco a formatear.
    # Comandos Utilizados:
    #     parted: programa de particionado.
    #     mklabel: crea o modifica la tabla de particiones al disco.

    sudo parted -s $DISCO mklabel gpt
}

crear_particiones() {
    # Variables .conf:
    #     DISCO: Disco a formatear.
    #     CANT_PARTICIONES: Cantidad de particiones a crear.
    #     PART_SIZE: Tamaño de las particiones en GB.
    # Comandos Utilizados:
    #     parted: programa de particionado.
    #     opciones:
    #         -s, --script: sin interactividad.
    #     mkpart: crea una nueva partición.
    #     opciones:
    #         primary: define la particion como primaria.
    #         ext4: define el sistema de archivos como ext4.
    #
    INICIO=0
    for i in $(seq 1 $CANT_PARTICIONES); do
        FIN=$(($INICIO + $TAMANO_PARTICION))
        sudo parted -s $DISCO mkpart primary ext4 ${INICIO}GB ${FIN}GB
        INICIO=$FIN
    done
}

formatear_particiones() {
    # Variables .conf:
    #     DISCO: Disco a formatear.
    #     CANT_PARTICIONES: Cantidad de particiones a crear.
    # Comandos Utilizados:
    #     mkfs.ext4: formatea una partición con el sistema de archivos ext4.

    for i in $(seq 1 $CANT_PARTICIONES); do
        sudo mkfs.ext4 $DISCO$i >/dev/null 2>&1
    done
}
