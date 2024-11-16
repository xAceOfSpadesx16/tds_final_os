#!/bin/bash
source trebol.conf

# Definicion de Array para paquetes faltantes
missing_packages=()

# Comprobacion de paquetes
for package in "${req_packages[@]}"; do
    if ! dpkg -l | grep -q "^ii  $package "; then
        missing_packages+=("$package")
    fi
done

# En caso de que todos los paquetes esten instalados finaliza el script correctamente
if [ ${#missing_packages[@]} -eq 0 ]; then
    echo "Todos los paquetes ya están instalados."
    exit 0
fi

# Mostrar los paquetes faltantes
echo "Los siguientes paquetes no están instalados:"
printf '%s\n' "${missing_packages[@]}"
echo
read -p "¿Desea instalarlos? (s/n): " -n 1 -r respuesta

# Validar la respuesta con un bucle while
while [[ "$respuesta" != "s" && "$respuesta" != "n" ]]; do
    echo "Entrada no válida."
    read -p "Por favor, ingrese 's' para sí o 'n' para no." -n 1 -r respuesta
done

# Actuar según la respuesta
if [[ "$respuesta" == "s" ]]; then
    echo "Actualizando paquetes..."
    sudo apt update

    echo "Instalando paquetes..."

    sudo apt install -y "${missing_packages[@]}"

    if [ $? -ne 0 ]; then
        echo "Hubo un error al instalar los paquetes."
        echo "Chequee el log de errores."
        echo "Ejecucion cancelada, corrija los errores e intente nuevamente."
        exit 1
    fi
else
    echo "No se instalaran los paquetes."
    echo "Ejecucion cancelada, los paquetes son requeridos para continuar."
    exit 1
fi
