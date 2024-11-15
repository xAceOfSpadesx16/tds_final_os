#!/bin/bash

source trebol.conf
copiar_listas() {
    # Variables:
    #     DIR_LISTS_PATH: Directorio donde se encontrarán las listas de usuarios.
    #
    # Comandos Utilizados:
    #     cp: copia archivos y directorios.
    #         opciones:
    #             -r: copia recursivamente.
    #             -f: fuerza la copia, ignorando errores.

    cp -rf "sectores/*" $DIR_LISTS_PATH
}
