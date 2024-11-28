source definicion/directorios.sh

obtener_directorios_a_montar() {
    # Devuelve un array con los directorios y tamaños para montaje.
    # Si el archivo temporal existe y no está vacío, usa su contenido.
    # De lo contrario, genera los directorios y los guarda en el archivo temporal.

    # Si el archivo temporal existe y tiene contenido, lo lee
    if [[ -f "$SYNC_DIRS_TMP" && -s "$SYNC_DIRS_TMP" ]]; then
        echo "Leyendo directorios desde $SYNC_DIRS_TMP..." >&2
        sudo mapfile -t directorios <"$SYNC_DIRS_TMP"
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
