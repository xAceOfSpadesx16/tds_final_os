#!/bin/bash
source trebol.conf

echo "Preparando paquetes..."
sudo bash samba/services.sh
echo

echo "Configurando Samba..."
sudo bash samba/config.sh
echo

echo "Configurando sincronizacion de tiempo..."
sudo bash samba/tiempo.sh
