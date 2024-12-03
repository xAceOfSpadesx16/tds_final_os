#!/bin/bash

# Script: Verificación e instalación de paquetes requeridos con configuración automática de Kerberos
# Descripción:
# Este script verifica la existencia de paquetes requeridos en el sistema.
# Si faltan paquetes, ofrece la opción de instalarlos automáticamente, configurando también Kerberos.
#
# 1. Verifica la existencia de los paquetes requeridos.
# 2. Si no faltan paquetes, muestra un mensaje y finaliza.
# 3. Si faltan, los lista y solicita al usuario autorización para instalarlos.
# 4. Si el usuario acepta:
#     - Actualiza la lista de paquetes.
#     - Configura Kerberos automáticamente usando `debconf-set-selections`.
#     - Instala los paquetes faltantes y Kerberos.
# 5. Si el usuario rechaza, finaliza indicando que los paquetes son necesarios.
#
# Comandos utilizados:
# - `source`:
#     - Carga las variables de configuración definidas en `trebol.conf`.
# - `dpkg -l`:
#     - Lista los paquetes instalados en el sistema.
#     opciones:
#         `^ii  $package`: Busca líneas que indiquen que el paquete está instalado.
# - `read`:
#     - Captura la entrada del usuario.
#     opciones:
#         `-p`: Muestra un mensaje antes de capturar la entrada.
#         `-n`: Limita la captura al número de caracteres especificados.
# - `sudo apt update`:
#     - Actualiza la lista de paquetes disponibles.
#     opciones:
#         `-qq`: Reduce la salida para mostrar solo errores críticos.
# - `debconf-set-selections`:
#     - Define configuraciones predeterminadas para paquetes que requieren interacción durante la instalación.
# - `sudo apt install`:
#     - Instala los paquetes requeridos.
#     opciones:
#         `-y`: Responde "sí" automáticamente a las solicitudes de confirmación.
#         `-qq`: Minimiza la salida.
# - `exit`:
#     - Finaliza el script con un código de estado.
# - `printf`:
#     - Imprime los elementos de un array en formato de lista.
# - `DEBIAN_FRONTEND`:
#     - Variable de entorno utilizada por `apt` y otros gestores de paquetes para definir el modo de interacción.
#     valores comunes:
#         `noninteractive`: Ejecuta el proceso de instalación sin pedir interacción del usuario. Ideal para scripts automatizados.

source trebol.conf

# Definicion de Array para paquetes faltantes
missing_packages=()

# Comprobacion de paquetes
echo "Comprobando existencia de paquetes requeridos..."
for package in "${req_packages[@]}"; do
    if ! dpkg -l | grep -q "^ii  $package "; then
        missing_packages+=("$package")
    fi
done

# En caso de que todos los paquetes esten instalados finaliza el script correctamente
if [ ${#missing_packages[@]} -eq 0 ]; then
    echo "Todos los paquetes ya están instalados."
    echo "Recuerdo configurar correctamente Kerberos."
    exit 0
fi

# Mostrar los paquetes faltantes
echo "Los siguientes paquetes no están instalados:"
printf '%s\n' "${missing_packages[@]}"
echo "A su vez se requieren los siguientes paquetes para configurar Kerberos:"
echo "krb5-config krb5-user"
echo
read -p "¿Desea instalarlos? (s/n): " -n 1 -r respuesta
echo

# Validar la respuesta con un bucle while
while [[ "$respuesta" != "s" && "$respuesta" != "n" ]]; do
    echo "Entrada no válida."
    read -p "Por favor, ingrese 's' para sí o 'n' para no." -n 1 -r respuesta
done

# Actuar según la respuesta
if [[ "$respuesta" == "s" ]]; then
    echo "Actualizando lista de paquetes..."
    sudo apt update -qq >/dev/null 2>/dev/null

    echo

    echo "Instalando paquetes requeridos..."

    # Definiendo solicitudes de Kerberos mediante debconf-set-selections
    echo "Definiendo Realm, Server y Admin Server en Kerberos mediante debconf..."
    echo "REALM=$REALM"
    echo "SERVER=$NOMBRE_CONTROLLER.$NOMBRE_DOMINIO.$EXTENSION_DOMINIO"
    echo "ADMIN_SERVER=$NOMBRE_CONTROLLER.$NOMBRE_DOMINIO.$EXTENSION_DOMINIO"

    echo "krb5-config krb5-config/default_realm string $REALM" | sudo debconf-set-selections
    echo "krb5-config krb5-config/kerberos_servers string $NOMBRE_CONTROLLER.$NOMBRE_DOMINIO.$EXTENSION_DOMINIO" | sudo debconf-set-selections
    echo "krb5-config krb5-config/admin_server string $NOMBRE_CONTROLLER.$NOMBRE_DOMINIO.$EXTENSION_DOMINIO" | sudo debconf-set-selections

    echo
    echo "Instalando Kerberos..."
    sudo DEBIAN_FRONTEND=noninteractive apt install -y -qq krb5-config krb5-user >/dev/null 2>/dev/null
    echo
    echo "Instalando paquetes requeridos..."
    sudo apt install -y -qq "${missing_packages[@]}" >/dev/null 2>/dev/null
    if [ $? -ne 0 ]; then
        echo "Hubo un error al instalar los paquetes."
        echo "Chequee el log de errores."
        echo "Ejecucion cancelada, corrija los errores e intente nuevamente."
        exit 1
    else
        echo "Instalacion de paquetes completada correctamente."
        exit 0
    fi
else
    echo "No se instalaran los paquetes."
    echo "Ejecucion cancelada, los paquetes son requeridos para continuar."
    exit 1
fi
