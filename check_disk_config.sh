#!/bin/bash
source trebol.conf

MENSAJE_ERROR="Ejecucion abortada. Revisar la configuracion en trebol.conf"

# Verificar que el disco existe
if [ ! -e "$DISCO" ]; then
    echo "Error: El disco $DISCO no existe."
    echo $MENSAJE_ERROR
    exit 1
fi

# Verificar que CANT_PARTICIONES esté en el rango válido
if [ "$CANT_PARTICIONES" -lt 1 ] || [ "$CANT_PARTICIONES" -gt 4 ]; then
    echo "Error: El número de particiones debe estar entre 1 y 4."
    echo "CANT_PARTICIONES: $CANT_PARTICIONES"
    echo $MENSAJE_ERROR
    exit 1
fi

# Verificar que TAMANO_PARTICION sea positivo
if [ "$TAMANO_PARTICION" -le 0 ]; then
    echo "Error: El tamaño de las particiones debe ser mayor que 0."
    echo "TAMANO_PARTICION: $TAMANO_PARTICION"
    echo $MENSAJE_ERROR
    exit 1
fi

# Verificar que el disco tenga suficiente espacio
TAMANO_DISCO=$(lsblk -b -o SIZE "$DISCO" | tail -n 1)
TAMANO_DISCO_GB=$(($TAMANO_DISCO / 1024 / 1024 / 1024))

# Calcular el espacio requerido para las particiones
ESPACIO_REQUERIDO=$(($CANT_PARTICIONES * $TAMANO_PARTICION))

if [ "$TAMANO_DISCO_GB" -lt "$ESPACIO_REQUERIDO" ]; then
    echo "Error: El disco no tiene suficiente espacio. Requiere $ESPACIO_REQUERIDO GB."
    echo "TAMANO_DISCO: $TAMANO_DISCO_GB GB"
    echo $MENSAJE_ERROR
    exit 1
fi

# Verificar si el disco tiene sistema de archivos
if [ -b "$DISCO" ] && sfdisk -l "$DISCO" >/dev/null 2>&1; then

    echo "Advertencia: El disco $DISCO ya tiene un sistema de archivos."
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
