#!/bin/bash
source trebol.conf

MENSAJE_ERROR="Ejecucion abortada. Revisar la configuracion en trebol.conf"

# Verificar que el disco existe
# Si el disco no existe
if [ ! -e "$DISCO" ]; then
    echo "Error: El disco $DISCO no existe."
    echo $MENSAJE_ERROR
    exit 1
fi

if [ ! -b "$DISCO" ]; then
    echo "Error: El disco $DISCO no es un dispositivo de bloque valido."
    echo "Ejecucion abortada, asegurese de que el disco sea un dispositivo de bloque valido."
    exit 1
fi

# Verificar que CANT_PARTICIONES esté en el rango válido
# Si la cantidad de particiones es menor a 1 o mayor a 4
if [ "$CANT_PARTICIONES" -lt 1 ] || [ "$CANT_PARTICIONES" -gt 4 ]; then
    echo "Error: El número de particiones debe estar entre 1 y 4."
    echo "CANT_PARTICIONES: $CANT_PARTICIONES"
    echo $MENSAJE_ERROR
    exit 1
fi

# Verificar que TAMANO_PARTICION sea positivo
# Si TAMANO_PARTICION es menor o igual a 0
if [ "$TAMANO_PARTICION" -le 0 ]; then
    echo "Error: El tamaño de las particiones debe ser mayor que 0."
    echo "TAMANO_PARTICION: $TAMANO_PARTICION"
    echo $MENSAJE_ERROR
    exit 1
fi

# Verificar que el disco tenga suficiente espacio
# Obtener el tamaño del disco en bytes
# Opciones: -b, --bytes: muestra el tamaño del disco en bytes
#           -o, --output: muestra el tamaño del disco en bytes
#           SIZE: muestra el tamaño del disco
#tail -n 1: muestra la ultima linea
TAMANO_DISCO=$(lsblk -b -o SIZE "$DISCO" | tail -n 1)
TAMANO_DISCO_GB=$(($TAMANO_DISCO / 1024 / 1024 / 1024))

# Calcular el espacio requerido para las particiones
ESPACIO_REQUERIDO=$(($CANT_PARTICIONES * $TAMANO_PARTICION))

# Si el tamaño del disco es menor al espacio requerido
if [ "$TAMANO_DISCO_GB" -lt "$ESPACIO_REQUERIDO" ]; then
    echo "Error: El disco no tiene suficiente espacio. Requiere $ESPACIO_REQUERIDO GB."
    echo "TAMANO_DISCO: $TAMANO_DISCO_GB GB"
    echo $MENSAJE_ERROR
    exit 1
fi

# Verificar si el disco tiene sistema de archivos
# Si el disco tiene una particion existente
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
        echo "Es requerido que el disco no tenga un sistema de archivos o sea sobrescrito."
        exit 1
    fi

fi
