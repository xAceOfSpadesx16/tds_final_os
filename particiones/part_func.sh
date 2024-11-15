#!/bin/bash
source trebol.conf

crear_tabla_particiones() {
    sudo parted -s $DISCO mklabel gpt
}

crear_particiones() {
    for i in $(seq 1 $CANT_PARTICIONES); do
        sudo parted -s $DISCO mkpart primary ext4 $((i * PART_SIZE + 1))GB $((i * PART_SIZE + PART_SIZE))GB
    done
}

formatear_particiones() {
    for i in $(seq 1 $CANT_PARTICIONES); do
        sudo mkfs.ext4 $DISCO$i >/dev/null 2>&1
    done
}
