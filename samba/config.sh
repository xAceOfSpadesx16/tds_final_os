#!/bin/bash
source trebol.conf

echo "Haciendo copia de seguridad de /etc/samba/smb.conf..."
sudo mv /etc/samba/smb.conf /etc/samba/smb.conf.bak
echo

echo "Definir provisionamiento de dominio..."
echo "Realm: $FQDN"
echo "Domain: $DOMAIN"
echo "Server Role: $SERVER_ROLE"
echo "DNS backend: $DNS_BACKEND"
echo "DNS forwarder IP address: $GOOGLE_DNS"
echo "Administrator password: $ADMINISTRATOR_PASSWORD"
echo "No olvides cambiar la contraseña del administrador"
echo "Comando: sudo samba-tool user setpassword administrator"
echo

sudo samba-tool domain provision --admin-pass="$ADMINISTRATOR_PASSWORD"

if [ $? -ne 0 ]; then
    echo "Error al definir provisionamiento de dominio."
    echo "Checkee el archivo ./samba/config.sh y la configuracion en trebol.conf"
    echo "Tambien puedes hacerlo manualmente."
    echo "Ejecuta el comando 'sudo samba-tool domain provision' para definirlo interactivamente"
else
    echo "Provisionamiento de dominio completado."
    echo "Realm: $FQDN"
    echo "Domain: $DOMAIN"
    echo "Server Role: $SERVER_ROLE"
    echo "DNS backend: $DNS_BACKEND"
    echo "DNS forwarder IP address: $GOOGLE_DNS"
    echo "Administrator password: $ADMINISTRATOR_PASSWORD"
    echo "No olvides cambiar la contraseña del administrador"
    echo "Comando: sudo samba-tool user setpassword administrator"
fi
echo

#!/bin/bash

echo "Creando zona de búsqueda inversa 18.168.192.in-addr.arpa en el servidor..."
sudo samba-tool dns zonecreate 127.0.0.1 18.168.192.in-addr.arpa -U administrator --password=$ADMINISTRATOR_PASSWORD 2>/dev/null

echo "Agregando registro A para trebol.local apuntando a 192.168.18.14..."
sudo samba-tool dns add 127.0.0.1 trebol.local trebol.local A 192.168.18.14 -U administrator --password=$ADMINISTRATOR_PASSWORD 2>/dev/null

echo "Ajustando registro PTR para que 192.168.18.14 apunte a trebol.local..."
sudo samba-tool dns add 127.0.0.1 18.168.192.in-addr.arpa 14 PTR trebol.local -U administrator --password=$ADMINISTRATOR_PASSWORD 2>/dev/null

echo

echo "Haciendo copia de seguridad de /etc/krb5.conf..."
sudo mv /etc/krb5.conf /etc/krb5.conf.back

echo

echo "Copiando /var/lib/samba/private/krb5.conf a /etc/krb5.conf..."
sudo cp /var/lib/samba/private/krb5.conf /etc/krb5.conf

echo

echo "Iniciando el servicio Samba Active Directory Domain Controller..."
sudo systemctl start samba-ad-dc

echo

echo "Verificando el estado del servicio..."
sudo systemctl status samba-ad-dc --no-pager

echo
