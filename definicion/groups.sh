#!/bin/bash

source trebol.conf
source utils.sh

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
    # Descripción:
    #     Crea grupos en el controlador de dominio utilizando Samba, basándose en los nombres obtenidos por la función obtener_grupos.
    #
    # Variables Utilizadas:
    #     Ninguna directamente en esta función (depende de obtener_grupos).
    #
    # Comandos Utilizados:
    #     samba-tool: herramienta para gestionar objetos en el dominio Samba.
    #         subcomandos:
    #             - group list: lista los grupos existentes en el dominio.
    #             - group add: agrega un nuevo grupo al dominio.
    #     grep: busca coincidencias en las líneas de salida.
    #         opciones:
    #             - -q: modo silencioso, no muestra salida.
    #             - -w: coincide solo con palabras completas.

    local grps=($(obtener_grupos))
    for i in "${grps[@]}"; do
        if ! samba-tool group list | grep -qw "$i"; then
            echo "Creando grupo $i." >&2
            sudo samba-tool group add "$i" >/dev/null 2>&1
            check_error $? "Error al crear el grupo $i."
        fi
    done
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    crear_groups
fi
