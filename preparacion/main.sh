#!/bin/bash

# Descripción:
#     Este script configura el hostname y la resolución de nombres en un servidor.
#     Realiza las siguientes acciones:
#     1. Define el hostname utilizando `hostnamectl`.
#     2. Limpia el archivo `/etc/hosts` de entradas antiguas del hostname.
#     3. Agrega una nueva línea al archivo `/etc/hosts` con la IP y el nombre de dominio completo (FQDN).
#     4. Verifica el FQDN usando el comando `hostname -f` y la resolución de nombres mediante `ping`.
#     5. Deshabilita `systemd-resolved` y elimina el enlace simbólico a `/etc/resolv.conf`.
#     6. Crea un nuevo archivo `/etc/resolv.conf` con configuraciones de DNS y lo hace inmutable.

#
# Comandos Utilizados:
#     sudo hostnamectl set-hostname: define el hostname del sistema.
#     sudo sed: edita archivos de texto usando expresiones regulares.
#         opciones:
#             - -i: edita el archivo en el lugar (sin crear un archivo de salida).
#             - "/127\.0\.1\.1\s\+$NOMBRE_CONTROLLER/d": elimina líneas con la dirección 127.0.1.1 seguida del nombre del controlador.
#     grep: busca cadenas de texto dentro de archivos.
#         opciones:
#             - -qF: busca la cadena exacta sin mostrar salida (modo silencioso).
#     sudo tee: lee desde la entrada estándar y escribe en archivos con privilegios de superusuario.
#     hostname -f: muestra el nombre completo del host (FQDN).
#     ping: prueba la conectividad de red con otro dispositivo.
#         opciones:
#             - -c2: realiza 2 intentos de ping.
#     sudo systemctl disable --now systemd-resolved: desactiva el servicio `systemd-resolved` inmediatamente.
#     sudo unlink: elimina un enlace simbólico.
#     sudo tee /etc/resolv.conf: crea o reemplaza el archivo `/etc/resolv.conf` con la configuración de DNS.
#         contenido:
#             - nameserver $ip: define el servidor DNS a la IP proporcionada.
#             - nameserver $GOOGLE_DNS: agrega el servidor DNS de Google.
#             - search $NOMBRE_DOMINIO.$EXTENSION_DOMINIO: establece el dominio de búsqueda para la resolución de nombres.
#     sudo chattr +i: hace inmutable un archivo, evitando su modificación.
#         opciones:
#             - +i: establece el atributo inmutable en el archivo.

trap 'sleep 1' DEBUG
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
