#!/bin/bash
source trebol.conf
source particiones/part_utils.sh

MENSAJE_ERROR="Ejecucion abortada. Revisar la configuracion en trebol.conf"

# Obtiene los directorios y tamaños definidos
directorios_y_tamanos=($(obtener_directorios_a_montar))

# Verifica que el disco existe
if [ ! -e "$DISCO" ]; then
    echo "Error: El disco $DISCO no existe."
    echo $MENSAJE_ERROR
    exit 1
else
    echo "El disco $DISCO existe..."
fi

# Verifica que el disco es un dispositivo de bloque válido
if [ ! -b "$DISCO" ]; then
    echo "Error: El disco $DISCO no es un dispositivo de bloque valido."
    echo "Ejecucion abortada, asegurese de que el disco sea un dispositivo de bloque valido."
    exit 1
else
    echo "El disco $DISCO es un dispositivo de bloque valido..."
fi

# Calcula el espacio requerido sumando los tamaños de todas las particiones
ESPACIO_REQUERIDO=0
for entry in "${directorios_y_tamanos[@]}"; do
    IFS=":" read -r _ size <<<"$entry"
    ESPACIO_REQUERIDO=$(($ESPACIO_REQUERIDO + size))
done

# Obtiene el tamaño del disco en GB
TAMANO_DISCO=$(lsblk -b -o SIZE "$DISCO" | tail -n 1)
TAMANO_DISCO_GB=$(($TAMANO_DISCO / 1024 / 1024 / 1024))

# Verifica que el disco tenga suficiente espacio
if [ "$TAMANO_DISCO_GB" -lt "$ESPACIO_REQUERIDO" ]; then
    echo "Error: El disco no tiene suficiente espacio. Requiere $ESPACIO_REQUERIDO GB."
    echo "TAMANO_DISCO: $TAMANO_DISCO_GB GB"
    echo $MENSAJE_ERROR
    exit 1
else
    echo "El disco $DISCO tiene suficiente espacio para crear las particiones requeridas."
fi

# Verifica si el disco tiene particiones existentes
if parted -s "$DISCO" print 1 &>/dev/null; then
    echo "Advertencia: El disco $DISCO ya tiene al menos una particion."
    echo "¿Desea sobrescribir las particiones existentes y crear nuevas? (s/n)"
    read -r overwrite

    while [[ "$overwrite" != "s" && "$overwrite" != "n" ]]; do
        echo "Por favor, ingrese 's' para sí o 'n' para no."
        read -r overwrite
    done

    if [[ "$overwrite" != "s" ]]; then
        echo "Ejecucion abortada."
        echo "Es requerido que el disco no tenga particiones existentes o sea sobrescrito."
        exit 1
    fi
else
    echo "El disco $DISCO no tiene un sistema de archivos..."
    echo "Posteriormente se crearan las particiones correspondientes..."
fi
