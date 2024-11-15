#!/bin/bash

source trebol.conf

obtener_grupos() {
    # Variables .conf:
    #     DIR_LISTS_PATH: Directorio donde se encuentran los listados.
    #
    # Comandos Utilizados:
    #     ls: lista archivos en el directorio especificado.
    #         opciones:
    #             - 2>/dev/null: suprime los errores si no existen archivos .list.
    #     xargs: transforma los nombres de archivo en una lista manejable.
    #         opciones:
    #             - -n 1: asegura que basename procese un archivo a la vez.
    #     basename: elimina la ruta y la extensión .list de cada archivo.
    #         opciones:
    #             - -s, --suffix: elimina la extensión especificada (.list en este caso)

    local nombres=($(ls "$DIR_LISTS_PATH"/*.list 2>/dev/null | xargs -n 1 basename -s .list))
    echo "${nombres[@]}"
}

crear_groups() {
    local grps=($(obtener_grupos))
    for i in "${grps[@]}"; do
        if ! getent group "$i" >/dev/null 2>&1; then
            sudo groupadd "$i"
        fi
    done
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    crear_groups
fi
