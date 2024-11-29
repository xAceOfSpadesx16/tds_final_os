#!/bin/bash

source trebol.conf
# Agrega un "sleep 1" despues de cada comando ejecutado para mejor debug
trap 'sleep 1' DEBUG

# Creación de estructura de directorios, definicion de archivos en skel, listas de usuarios.
echo "Creando estructura de directorios y copiado de archivos necesarios."

sudo bash definicion/main.sh

echo -e "Creacion de estructura de directorios finalizada.\n"

echo

# Check de Configuración de Disco a particionar
echo "Verificando disco $DISCO..."
sudo bash check_disk_config.sh
if [ $? -ne 0 ]; then
    exit 1
else
    echo -e "Verificacion de disco $DISCO finalizada.\n"
fi

# Check de paquetes requeridos
sudo bash check_pack_req.sh
if [ $? -ne 0 ]; then
    exit 1
fi

# Preparacion de Servidor
sudo bash preparacion/main.sh
if [ $? -ne 0 ]; then
    echo "Error al preparar el servidor, la instalacion ha sido abortada."
    echo "Checkee el archivo ./preparacion/main.sh y la configuracion en trebol.conf"
    exit 1
fi

# Particionado de disco
echo "Iniciando particionado de disco $DISCO."

sudo bash particiones/main.sh

echo -e "Particionado de disco $DISCO ha finalizado.\n"

echo "Montando particiones..."
sudo bash particiones/montaje.sh
echo -e "Montaje de particiones finalizado.\n"

echo

echo "Configurando Samba Active Directory..."
sudo bash samba/main.sh
echo -e "Configuracion de Samba finalizada.\n"

# # Creacion de grupos definidos en problematica trebol (acorde a archivos .list)
# echo "Definiendo grupos."

sudo bash definicion/groups.sh

echo -e "Definicion de Grupos finalizada.\n"

# # Definicion de nuevo alias para creacion usuarios.

# |||||||||||||||||||||||||||||||||||||||||||

# # Creacion de usuarios definidos en problematica trebol
echo "Creando usuarios de $empresa"

sudo bash users/auto.sh

echo -e "Creacion de Usuarios finalizada.\n"

# # Definicion de permisos de arbol y propietarios de directorios
echo "Definiendo propietarios y permisos."

sudo bash definicion/own_perms.sh

echo -e "Definicion de propietarios y permisos finalizada.\n"

# # Definicion de Recursos compartidos

echo "Definiendo recursos compartidos."

sudo bash shared/main.sh

echo -e "Definicion de Recursos compartidos finalizada.\n"

echo "Instalacion finalizada."
