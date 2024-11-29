#!/bin/bash

source trebol.conf
source definicion/directorios.sh
source shared/shared_func.sh

main() {

    crear_shared_home

    areas=($(obtener_grupos_no_principales))
    # hacer for recorriendo areas de trabajo, definir estructura para todos.
    for area in "${areas[@]}"; do

        echo "Creando recurso compartido para area de trabajo: $area" >&2

        creacion_no_interactiva_recurso_compartido "$area" \
            "$DIR_ROOT_PATH/$area" \
            "" \
            "yes" \
            "$SECTOR_DIR_OWNER @$area" \
            "$SECTOR_DIR_OWNER" \
            "640" \
            "2750" \
            "Area de trabajo: $area" \
            "" \
            ""

    done
    check_parm_y_reinicio_servicios
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
