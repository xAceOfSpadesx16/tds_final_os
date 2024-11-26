#!/bin/bash
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
    sudo apt update -q

    echo

    echo "Instalando paquetes requeridos..."

    # Definiendo solicitudes de Kerberos mediante debconf-set-selections
    # Se utiliza DEBIAN_FRONTEND=noninteractive para evitar la interaccion con el usuario durante la instalacion
    # Por lo tanto se utiliza este para definir la informacion requerida por el paquete.
    echo "Definiendo Realm, Server y Admin Server en Kerberos mediante debconf..."
    echo "REALM=$FQDN"
    echo "SERVER=$NOMBRE_CONTROLLER.$NOMBRE_DOMINIO.$EXTENSION_DOMINIO"
    echo "ADMIN_SERVER=$NOMBRE_CONTROLLER.$NOMBRE_DOMINIO.$EXTENSION_DOMINIO"

    echo "krb5-config krb5-config/default_realm string $FQDN" | sudo debconf-set-selections
    echo "krb5-config krb5-config/kerberos_servers string $NOMBRE_CONTROLLER.$NOMBRE_DOMINIO.$EXTENSION_DOMINIO" | sudo debconf-set-selections
    echo "krb5-config krb5-config/admin_server string $NOMBRE_CONTROLLER.$NOMBRE_DOMINIO.$EXTENSION_DOMINIO" | sudo debconf-set-selections

    echo
    echo "Instalando Kerberos..."
    sudo DEBIAN_FRONTEND=noninteractive apt install -y -qq krb5-config krb5-user
    echo
    echo "Instalando paquetes requeridos..."
    sudo apt install -y -q "${missing_packages[@]}"
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
