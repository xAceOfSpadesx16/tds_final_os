#!/bin/bash
# trap 'sleep 1' DEBUG
source trebol.conf
source utils.sh

ip=$(obtener_ip)
# Definiendo el hostname
echo "Definiendo el hostname como $NOMBRE_CONTROLLER..."
sudo hostnamectl set-hostname $NOMBRE_CONTROLLER

# Limpiando /etc/hosts
echo "Limpiando /etc/hosts..."
# sudo sed -i "/127\.0\.0\.1\s\+$NOMBRE_CONTROLLER/d" /etc/hosts #elimina la linea 127.0.0.1 dc en caso de existir
sudo sed -i "/127\.0\.1\.1\s\+$NOMBRE_CONTROLLER/d" /etc/hosts #elimina la linea 127.0.1.1 dc en caso de existir

# Definiendo la resolución de nombres local
echo "Definiendo la resolución de nombres local en /etc/hosts..."
echo "dominio: $NOMBRE_CONTROLLER.$NOMBRE_DOMINIO.$EXTENSION_DOMINIO $NOMBRE_CONTROLLER"
echo "apuntando al ip: $ip"
LINEA="$ip $NOMBRE_CONTROLLER.$NOMBRE_DOMINIO.$EXTENSION_DOMINIO $NOMBRE_CONTROLLER"

if ! grep -qF "$LINEA" /etc/hosts; then
    echo "$LINEA" | sudo tee -a /etc/hosts >/dev/null
else
    echo "La línea ya existe en /etc/hosts: $LINEA"
fi
echo

# Verificando el FQDN
echo "Verificando el FQDN..."
hostname -f
echo

# Verificando la resolución de nombres
echo "Haciendo ping a $NOMBRE_CONTROLLER.$NOMBRE_DOMINIO.$EXTENSION_DOMINIO..."
ping -c2 "$NOMBRE_CONTROLLER"."$NOMBRE_DOMINIO"."$EXTENSION_DOMINIO"
echo

# Deshabilitando systemd-resolved
echo "Deshabilitando el servicio systemd-resolved..."
sudo systemctl disable --now systemd-resolved
echo

# Eliminando enlace simbólico de resolv.conf
echo "Eliminando enlace simbólico de resolv.conf..."
sudo unlink /etc/resolv.conf
echo

# Creando nuevo resolv.conf
echo "Creando nuevo archivo resolv.conf..."
sudo tee /etc/resolv.conf >/dev/null <<EOF
nameserver $ip
nameserver $GOOGLE_DNS
search $NOMBRE_DOMINIO.$EXTENSION_DOMINIO
EOF
echo

# Haciendo inmutable al archivo /etc/resolv.conf
echo "Haciendo inmutable al archivo /etc/resolv.conf"
sudo chattr +i /etc/resolv.conf
echo
