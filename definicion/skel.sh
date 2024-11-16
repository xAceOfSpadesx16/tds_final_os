#!/bin/bash

source trebol.conf

copiar_a_skel() {
    # Variables:
    #     USE_SKEL: Directorio skel utilizado para los usuarios.
    #
    # Comandos Utilizados:
    #     cp: copia archivos y directorios.
    #         opciones:
    #             -r: copia recursivamente.
    #             -f: fuerza la copia, ignorando errores.

    cp -rf "skel/"* "$USE_SKEL"
}
