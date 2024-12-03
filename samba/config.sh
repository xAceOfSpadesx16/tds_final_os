#!/bin/bash

# Descripción:
#     Este script realiza la provisión de un dominio Samba Active Directory (AD) y configura
#     archivos relacionados. Las acciones que realiza son las siguientes:
#     1. Hace una copia de seguridad del archivo de configuración `/etc/samba/smb.conf`.
#     2. Define el provisionamiento del dominio utilizando `samba-tool domain provision`.
#     3. Realiza la provisión del dominio y muestra información sobre el proceso.
#     4. Hace una copia de seguridad de `/etc/krb5.conf`.
#     5. Copia el archivo de configuración Kerberos generado por Samba a `/etc/krb5.conf`.
#     6. Inicia el servicio Samba Active Directory Domain Controller (`samba-ad-dc`).
#     7. Verifica el estado del servicio `samba-ad-dc`.

#
# Comandos Utilizados:
#     sudo mv: mueve o renombra archivos o directorios.
#     sudo samba-tool domain provision: realiza la provisión del dominio Samba AD.
#         opciones:
#             - --realm: especifica el nombre del realm (dominio completo).
#             - --domain: define el nombre del dominio.
#             - --server-role: establece el rol del servidor, como "dc" (controlador de dominio).
#             - --dns-backend: define el backend de DNS a usar.
#             - --dns-forwarder: especifica la dirección IP del reenvío de DNS.
#             - --admin-password: define la contraseña del administrador.
#     sudo cp: copia archivos de un lugar a otro.
#         opciones:
#             - /var/lib/samba/private/krb5.conf: archivo de configuración Kerberos generado por Samba.
#             - /etc/krb5.conf: archivo de destino de la configuración Kerberos.
#     sudo systemctl start: inicia un servicio en el sistema.
#     sudo systemctl status: muestra el estado de un servicio.
#         opciones:
#             - --no-pager: evita que la salida se pagine.

source trebol.conf

echo "Haciendo copia de seguridad de /etc/samba/smb.conf..."
sudo mv /etc/samba/smb.conf /etc/samba/smb.conf.bak
echo

echo "Definir provisionamiento de dominio..."
echo "Realm: $REALM"
echo "Domain: $DOMAIN"
echo "Server Role: $SERVER_ROLE"
echo "DNS backend: $DNS_BACKEND"
echo "DNS forwarder IP address: $GOOGLE_DNS"
echo "Administrator password: $ADMINISTRATOR_PASSWORD"
echo "No olvides cambiar la contraseña del administrador"
echo "Comando: sudo samba-tool user setpassword administrator"
echo

sudo samba-tool domain provision

if [ $? -ne 0 ]; then
    echo "Error al definir provisionamiento de dominio."
    echo "Checkee el archivo ./samba/config.sh y la configuracion en trebol.conf"
    echo "Tambien puedes hacerlo manualmente."
    echo "Ejecuta el comando 'sudo samba-tool domain provision' para definirlo interactivamente"
else
    echo "Provisionamiento de dominio completado."
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
