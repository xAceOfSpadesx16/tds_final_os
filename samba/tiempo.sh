#!/bin/bash

# Descripción:
#     Este script configura el servicio NTP (Network Time Protocol) en el sistema utilizando `chrony`.
#     Define los permisos y propietario del archivo de configuración `ntp_signd`, y luego modifica el archivo
#     `/etc/chrony.conf` para agregar configuraciones necesarias. Finalmente, reinicia el servicio `chronyd` y verifica su estado.
#
# Comandos Utilizados:
#     sudo chown: cambia el propietario de un archivo o directorio.
#         opciones:
#             - root:_chrony: el propietario se establece como `root` y el grupo como `_chrony`.
#     sudo chmod: cambia los permisos de un archivo o directorio.
#     sudo tee -a: escribe la salida estándar al archivo especificado.
#         opciones:
#             - -a: añade el contenido al final del archivo sin sobrescribirlo.
#     sudo systemctl restart: reinicia un servicio del sistema.
#     sudo systemctl status: muestra el estado de un servicio del sistema.
#         opciones:
#             - --no-pager: evita el uso de un paginador al mostrar la salida.
#
source trebol.conf
source utils.sh

echo "Definiendo propietario para ntp_signd..."
sudo chown root:_chrony "$NTPSIGND_PATH"

echo

echo "Definiendo permisos para ntp_signd..."
sudo chmod 750 "$NTPSIGND_PATH"

echo

echo "Modificando archivo /etc/chrony.conf..."
sudo tee -a /etc/chrony.conf >/dev/null <<EOF
bindcmdaddress $(obtener_ip)
allow $(obtener_red)
ntpsigndsocket $NTPSIGND_PATH
EOF

echo

echo "Reiniciando el servicio chronyd..."
sudo systemctl restart chronyd

echo

echo "Verificando el estado del servicio..."
sudo systemctl status chronyd --no-pager

echo
