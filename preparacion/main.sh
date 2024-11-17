#!/bin/bash

source trebol.conf
source utils.sh

ip=$(obtener_ip)
# Definiendo el hostname
echo "Definiendo el hostname como $NOMBRE_CONTROLLER..."
sudo hostnamectl set-hostname $NOMBRE_CONTROLLER

# Limpiando /etc/hosts
echo "Limpiando /etc/hosts..."
sudo sed -i "/127\.0\.0\.1\s\+$NOMBRE_CONTROLLER/d" /etc/hosts #elimina la linea 127.0.0.1 dc en caso de existir

# Definiendo la resolución de nombres local
echo "Definiendo la resolución de nombres local en /etc/hosts..."
echo "dominio: $NOMBRE_CONTROLLER.$NOMBRE_DOMINIO.$EXTENSION_DOMINIO $NOMBRE_CONTROLLER"
echo "apuntando al ip: $ip"
echo "$ip $NOMBRE_CONTROLLER.$NOMBRE_DOMINIO.$EXTENSION_DOMINIO $NOMBRE_CONTROLLER" | sudo tee -a /etc/hosts >/dev/null
echo
# Verificando el FQDN
echo "Verificando el FQDN..."
hostname -f
echo

echo "Haciendo ping a $NOMBRE_CONTROLLER.$NOMBRE_DOMINIO.$EXTENSION_DOMINIO..."
ping -c2 "$NOMBRE_CONTROLLER"."$NOMBRE_DOMINIO"."$EXTENSION_DOMINIO"
echo

echo "Deshabilitando el servicio systemd-resolved..."
sudo systemctl disable --now systemd-resolved
echo

echo "Eliminando enlace simbólico de resolv.conf..."
sudo unlink /etc/resolv.conf
echo

echo "Creando enlace simbólico de resolv.conf..."
sudo tee /etc/resolv.conf >/dev/null <<EOF
nameserver $ip
nameserver $GOOGLE_DNS
search $NOMBRE_DOMINIO.$EXTENSION_DOMINIO
EOF
echo

echo "Haciendo inmutable al archivo /etc/resolv.conf"
sudo chattr +i /etc/resolv.conf
echo
