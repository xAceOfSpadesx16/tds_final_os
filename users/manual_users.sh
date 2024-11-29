#!/bin/bash
source users/user_func.sh
source trebol.conf
source definicion/directorios.sh

sector_list() {
    # Variables .conf:
    #     DIR_LISTS_PATH: Directorio donde se encuentran los listados0.
    #     MAIN_GRP: Grupo Principal se excluirá del listado.
    #
    # Comandos Utilizados:
    #     ls: lista archivos en el directorio especificado.
    #         opciones:
    #             - 2>/dev/null: suprime los errores si no existen archivos .list.
    #     grep: filtra el listado de archivos.
    #         opciones:
    #             - -v: excluye las líneas que contienen el nombre del grupo principal.
    #     xargs: transforma los nombres de archivo en una lista manejable.
    #         opciones:
    #             - -n 1: asegura que basename procese un archivo a la vez.
    #     basename: elimina la ruta y la extensión .list de cada archivo.
    #         opciones:
    #             - -s, --suffix: elimina la extensión especificada (.list en este caso) de cada nombre de archivo.
    #
    # Salida:
    #     Devuelve un array de nombres de archivos en el directorio DIR_LISTS_PATH que terminan en .list,
    #     excluyendo el archivo cuyo nombre coincide con MAIN_GRP.

    local nombres=($(ls "$DIR_LISTS_PATH"/*.list 2>/dev/null | grep -v "/$MAIN_GRP.list" | xargs -n 1 basename -s .list))
    echo "${nombres[@]}"
}

elegir_sector() {
    # Parámetros:
    #     $@) Array de sectores disponibles.
    #
    # Comandos Utilizados:
    #     echo: muestra los sectores disponibles y mensajes de error en caso de entrada incorrecta.
    #         opciones:
    #             - >&2: redirige la salida a stderr para mantener la selección en la terminal y no en la salida estándar.
    #     read: lee la entrada de usuario (número de un sector).
    #         opciones:
    #             - -p: muestra un mensaje para indicar lo que se espera como entrada.
    #
    # Expresiones Condicionales:
    #     [[ "$sector_index" =~ ^[0-9]+$ ]]: verifica que la entrada sea un número entero positivo.
    #     ((sector_index >= 1 && sector_index <= ${#sectores_disponibles[@]})): comprueba que el número ingresado esté dentro del rango de sectores disponibles.
    #
    # Salida:
    #     Devuelve el nombre del sector elegido por el usuario en la salida estándar (stdout).
    #     En caso de entrada incorrecta, muestra mensajes de error en stderr y vuelve a solicitar la entrada.

    local sectores_disponibles=("$@")
    local indice_elegido
    local sector

    echo "Sectores disponibles:" >&2
    for ((i = 1; i <= ${#sectores_disponibles[@]}; i++)); do
        echo "$i) ${sectores_disponibles[i - 1]}" >&2
        echo >&2
    done
    while true; do
        read -p "Ingrese el número del sector que le fue asignado: " indice_elegido

        if [[ "$indice_elegido" =~ ^[0-9]+$ ]]; then
            if ((indice_elegido >= 1 && indice_elegido <= ${#sectores_disponibles[@]})); then
                sector="${sectores_disponibles[$((indice_elegido - 1))]}"
                echo "$sector"
                return
            else
                echo "Opción fuera de rango. Por favor, ingrese un número entre 1 y ${#sectores_disponibles[@]}." >&2
                echo >&2
            fi
        else
            echo "Entrada no válida. Por favor, ingrese un número." >&2
            echo >&2
        fi
    done
}

main() {
    # Variables .conf:
    #     MAIN_GRP: Grupo Principal.
    # Tareas:
    #     Obtiene la lista de sectores disponibles.
    #     Solicita por entrada el nombre de usuario.
    #     Solicita por entrada el sector al que se desea agregar el usuario. (lista de sectores disponibles)
    #     Crea el usuario en la base de datos de Samba.
    #     Crea el home del usuario.
    #     Agrega el usuario al sector principal (listado).
    #     Agrega el usuario al sector elegido (listado).
    #     Agrega el usuario al grupo principal.
    #     Agrega el usuario al sector elegido.

    local sectores_disponibles=$((sector_list))

    local user
    read -p "Defina un nombre de Usuario: " user

    sector=$(elegir_sector "${sectores_disponibles[@]}")

    echo "Creando usuario $user en samba..."
    crear_usuario_samba "$user" 1

    echo "Creando home de $user..."
    crear_home_dir "$user"

    agregar_user_a_sector "$user" "$MAIN_GRP"

    agregar_user_a_sector "$user" "$sector"

    agregar_a_grp "$MAIN_GRP" "$user"

    agregar_a_grp "$sector" "$user"

}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
