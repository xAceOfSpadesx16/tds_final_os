#!/bin/bash

# Check de Configuración de Disco a particionar
sudo bash check_disk_config.sh
if [ $? -ne 0 ]; then
    exit 1
fi

# Particionado de disco
sudo bash particiones/main.sh

# Creación de estructura de directorios, definicion de archivos en skel, listas de usuarios.
sudo bash definicion/main.sh

# Creacion de grupos definidos en problematica trebol (acorde a archivos .list)
sudo bash definicion/groups.sh

#definir nuevo alias para creacion de nuevo usuario -> username y grupo (opciones acorde a archivos .list)

#crear usuarios definidos en problematica trebol
sudo bash users/auto.sh

#definir permisos de arbol y propietarios de directorios
sudo bash definicion/own_perms.sh

#

#
