#!/bin/bash

source trebol.conf
source definicion/directorios.sh
source shared/shared_func.sh

main() {
    # Descripción:
    #     Esta funcion centraliza la creación de recursos compartidos.
    #     Primero, crea el recurso compartido para homes de usuarios. Luego, recorre todas las áreas de trabajo y
    #     realiza la creación de recursos compartidos para cada una.
    #     Finalmente, verifica los parámetros y reinicia los servicios correspondientes.
    #
    # Parametros definidos para creacion_no_interactiva_recurso_compartido:
    #   - `$name`: nombre del recurso compartido (nombre del área de trabajo).
    #   - `$path`: ruta del directorio del recurso compartido (`$DIR_ROOT_PATH/$area`).
    #   - `$readonly`: si el recurso compartido será solo de lectura (`"yes"` para solo lectura, `"no"` para permitir escritura). Valor por defecto: `"no"`.
    #   - `$browseable`: si el recurso compartido será visible para los usuarios (`"yes"` para visible, `"no"` para oculto). Valor por defecto: `"no"`.
    #   - `$valid_users`: usuarios autorizados para acceder al recurso. Valor por defecto: `"@$MAIN_GRP"`, que hace referencia al grupo principal.
    #   - `$write_list`: lista de usuarios que pueden escribir en el recurso. Valor por defecto: vacío.
    #   - `$create_mask`: máscara de permisos para los archivos creados en el recurso compartido. Valor por defecto: `"640"`.
    #   - `$directory_mask`: máscara de permisos para los directorios creados en el recurso compartido. Valor por defecto: `"2750"`.
    #   - `$comment`: comentario o descripción del recurso compartido. Valor por defecto: vacío.
    #   - `$max_connections`: número máximo de conexiones simultáneas permitidas. Valor por defecto: vacío.
    #   - `$hosts_allow`: lista de hosts permitidos para acceder al recurso. Valor por defecto: vacío.
    #
    #     check_parm_y_reinicio_servicios: verifica que los parámetros de configuración sean correctos y reinicia los servicios necesarios.
    #         - `check_parm_y_reinicio_servicios`: función que valida la configuración y reinicia los servicios correspondientes si es necesario.

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
