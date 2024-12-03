source definicion/directorios.sh

obtener_directorios_a_montar() {
    # Descripción:
    #     Esta función obtiene una lista de directorios y tamaños para montar, ya sea leyendo de un archivo temporal
    #     si existe y tiene contenido, o generándolos dinámicamente a partir de una lista estática y areas de trabajo.
    #     Los directorios generados se guardan en un archivo temporal para futuras consultas.
    #
    # Comandos Utilizados:
    #     mapfile: lee el contenido de un archivo en un array.
    #         opciones:
    #             -t: elimina los saltos de línea al final de cada línea leída.
    #     sudo printf: imprime el contenido al archivo con privilegios de superusuario.
    #         opciones:
    #             - %s\n: imprime cada elemento en el array en una nueva línea.

    # Si el archivo temporal existe y tiene contenido, lo lee
    if [[ -f "$SYNC_DIRS_TMP" && -s "$SYNC_DIRS_TMP" ]]; then
        echo "Leyendo directorios desde $SYNC_DIRS_TMP..." >&2
        mapfile -t directorios <"$SYNC_DIRS_TMP"
        echo "${directorios[@]}"
        return
    fi

    echo "Generando directorios dinámicos..." >&2

    # Directorios definidos estáticamente
    local directorios=("${MOUNT_DIRS[@]}")

    # Directorios dinámicos generados a partir de los grupos no principales
    local grupos=($(obtener_grupos_no_principales))
    for grupo in "${grupos[@]}"; do
        directorios+=("$DIR_ROOT_PATH/$grupo:$TAMANO_PART_AREAS")
    done

    # Guardar el resultado en el archivo temporal
    echo "Guardando directorios en $SYNC_DIRS_TMP..." >&2
    sudo printf "%s\n" "${directorios[@]}" >"$SYNC_DIRS_TMP"

    # Devolver los directorios
    echo "${directorios[@]}"
}
