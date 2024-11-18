#!/bin/bash
source trebol.conf

echo "Haciendo copia de seguridad de /etc/samba/smb.conf..."
sudo mv /etc/samba/smb.conf /etc/samba/smb.conf.bak
echo

echo "Definiendo provisionamiento de dominio..."
sudo samba-tool domain provision \
    --realm=$FQDN \
    --domain=$DOMAIN \
    --server-role=$SERVER_ROLE \
    --dns-backend=$DNS_BACKEND \
    --adminpass=$ADMINISTRATOR_PASSWORD \
    --dns-forwarder=$GOOGLE_DNS \
    --use-rfc2307
# --interactive=no

echo "Realm: $FQDN"
echo "Domain: $DOMAIN"
echo "Server Role: $SERVER_ROLE"
echo "DNS backend: $DNS_BACKEND"
echo "DNS forwarder IP address: $GOOGLE_DNS"
echo "Administrator password: $ADMINISTRATOR_PASSWORD"
echo "No olvides cambiar la contraseña del administrador"
echo "Comando: sudo samba-tool user setpassword administrator"
echo
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
