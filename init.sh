#!/bin/bash

source trebol.conf

# Check de Configuración de Disco a particionar
sudo bash check_disk_config.sh
if [ $? -ne 0 ]; then
    exit 1
fi

# Check de paquetes requeridos
sudo bash check_pack_req.sh
if [ $? -ne 0 ]; then
    exit 1
fi

# Particionado de disco
echo "Iniciando particionado de disco $DISCO."

sudo bash particiones/main.sh

echo -e "Particionado de disco $DISCO ha finalizado.\n"

# Creación de estructura de directorios, definicion de archivos en skel, listas de usuarios.
echo "Creando estructura de directorios y copiado de archivos necesarios."

sudo bash definicion/main.sh

echo -e "Creacion de estructura de directorios finalizada.\n"

# Creacion de grupos definidos en problematica trebol (acorde a archivos .list)
echo "Definiendo grupos."

sudo bash definicion/groups.sh

echo -e "Definicion de Grupos finalizada.\n"

# Definicion de nuevo alias para creacion usuarios.

# Creacion de usuarios definidos en problematica trebol
echo "Creando usuarios de $empresa"

sudo bash users/auto.sh

echo -e "Creacion de Usuarios finalizada.\n"

# Definicion de permisos de arbol y propietarios de directorios
echo "Definiendo propietarios y permisos."

sudo bash definicion/own_perms.sh

echo -e "Definicion de propietarios y permisos finalizada.\n"

# Definiendo Active Directory

#
