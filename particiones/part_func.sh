#!/bin/bash
source trebol.conf

crear_tabla_particiones() {
    # Cambia la tabla de particiones a MBR para soportar particiones extendidas.
    # Variables .conf:
    #     DISCO: Disco a formatear.
    echo "Creando tabla de particiones MBR en $DISCO..."
    sudo parted -s $DISCO mklabel msdos
}

crear_particion_extendida() {
    # Crea una partición extendida que abarque todo el espacio necesario.
    # Variables .conf:
    #     DISCO: Disco a formatear.
    #     CANT_PARTICIONES: Cantidad de particiones lógicas a crear.
    #     TAMANO_PARTICION: Tamaño de cada partición en GB.
    local TAMANO_TOTAL=$((CANT_PARTICIONES * TAMANO_PARTICION))
    echo "Creando partición extendida de ${TAMANO_TOTAL}GB en $DISCO..."
    sudo parted -s $DISCO mkpart extended 0GB ${TAMANO_TOTAL}GB
}

crear_particiones_logicas() {
    # Crea particiones lógicas dentro de la extendida.
    # Variables .conf:
    #     DISCO: Disco a formatear.
    #     CANT_PARTICIONES: Cantidad de particiones lógicas a crear.
    #     TAMANO_PARTICION: Tamaño de cada partición en GB.
    local INICIO=0
    local FIN=0
    for i in $(seq 1 $CANT_PARTICIONES); do
        INICIO=$(($FIN + 1)) # La siguiente partición empieza después de la anterior.
        FIN=$(($INICIO + TAMANO_PARTICION - 1))
        echo "Creando partición lógica $i de ${TAMANO_PARTICION}GB (${INICIO}GB - ${FIN}GB)..."
        sudo parted -s $DISCO mkpart logical ${INICIO}GB ${FIN}GB
    done
}

formatear_particiones() {
    # Formatea las particiones lógicas creadas con el sistema de archivos ext4.
    # Variables .conf:
    #     DISCO: Disco a formatear.
    #     CANT_PARTICIONES: Cantidad de particiones a crear.
    echo "Formateando particiones lógicas en $DISCO..."
    for i in $(seq 5 $(($CANT_PARTICIONES + 4))); do
        echo "Formateando ${DISCO}$i como ext4..."
        sudo mkfs.ext4 ${DISCO}$i >/dev/null 2>&1
    done
}
