#!/bin/bash
source trebol.conf

check_error() {
    # Verifica si un comando ha generado un error y muestra un mensaje personalizado en caso de que ocurra.
    #
    # Argumentos:
    #     $1: Código de error del último comando ejecutado.
    #         - Normalmente se pasa `$?`, que contiene el estado de salida del comando anterior.
    #         - Un valor distinto de `0` indica un error.
    #     $2: Mensaje personalizado que se mostrará si ocurrió un error.
    #         - Este mensaje se mostrará en la salida estándar de error (stderr).
    #
    # Uso típico:
    #     Esta función se utiliza después de ejecutar comandos para verificar su éxito o fallo,
    #     especialmente en scripts donde la continuidad depende de que los comandos previos se ejecuten correctamente.
    #
    # Ejemplo de uso:
    #     algun_comando
    #     check_error $? "Error al ejecutar algun_comando"

    local error=$1
    local mensaje=$2

    if [ "$error" -ne 0 ]; then
        echo "Error: $mensaje" >&2
        return 1
    fi

    return 0
}

obtener_ip() {
    # Obtiene la dirección IP v4 asociada a un adaptador de red específico.
    #
    # Argumentos:
    #     $ADAPTADOR: Nombre del adaptador de red del cual se desea obtener la dirección IP.
    #                 - Puede ser `eth0`, `wlan0`, `enpXsY`, entre otros, según la configuración del sistema.
    #
    # Comandos Utilizados:
    #     ip: Muestra información sobre interfaces de red.
    #         - `-4 addr show $ADAPTADOR`: Filtra las direcciones IPv4 del adaptador especificado.
    #     grep: Busca patrones en la salida.
    #         - `-oP`: Imprime sólo las coincidencias, utilizando expresiones regulares compatibles con Perl.
    #         - `(?<=inet\s)\d+(\.\d+){3}`: Extrae direcciones IPv4 precedidas por "inet ".
    #
    # Salida:
    #     - Imprime en la salida estándar la dirección IPv4 asignada al adaptador especificado.
    #       Ejemplo: `192.168.1.100`
    #     - Si el adaptador no tiene una dirección IP o no existe, la salida estará vacía.
    #
    # Ejemplo de uso:
    #     ADAPTADOR="eth0"
    #     obtener_ip
    #     # Salida: 192.168.1.100
    #
    ip -4 addr show $ADAPTADOR | grep -oP '(?<=inet\s)\d+(\.\d+){3}'
}

obtener_red() {
    # Obtiene la dirección de red asociada a un adaptador de red específico.
    #
    # Validación previa:
    #     - Verifica si el adaptador especificado existe en el sistema.
    #
    # Argumentos:
    #     $ADAPTADOR: Nombre del adaptador de red del cual se desea obtener la dirección de red.
    #                 - Ejemplo: `eth0`, `wlan0`, `enpXsY`, etc.
    #
    # Comandos Utilizados:
    #     ip:
    #         - `link show $ADAPTADOR`: Verifica si el adaptador existe.
    #         - `addr show $ADAPTADOR`: Obtiene información sobre direcciones IP del adaptador.
    #     awk:
    #         - `/inet / {print $2}`: Extrae la dirección IP y la máscara en formato CIDR.
    #         - `/Network/ {print $2}`: Extrae la dirección de red de la salida de `ipcalc`.
    #     xargs:
    #         - `-I{}`: Sustituye `{}` con la entrada estándar para ejecutar `ipcalc`.
    #     ipcalc:
    #         - `-n`: Calcula la dirección de red a partir de una dirección en formato CIDR.
    #
    # Salida:
    #     - Imprime la dirección de red asociada al adaptador en formato IPv4.
    #       Ejemplo: `192.168.1.0`
    #     - Si el adaptador no tiene una dirección IP configurada o no existe, muestra un mensaje de error.

    # Comprueba si el adaptador de red existe
    if ! ip link show "$ADAPTADOR" >/dev/null 2>&1; then
        echo "Error: Adaptador $ADAPTADOR no encontrado o no válido." >&2
        return 1
    fi

    # Obtiene la dirección de red asociada al adaptador
    ip addr show "$ADAPTADOR" | awk '/inet / {print $2}' | xargs -I{} ipcalc -n {} | awk '/Network/ {print $2}'
}

input_min_chars() {
    # Solicita al usuario una entrada de texto y valida que tenga al menos un número mínimo de caracteres.
    #
    # Argumentos:
    #     $1: Mensaje a mostrar al usuario como prompt.
    #         - Ejemplo: "Introduce tu nombre: "
    #     $2: Nombre de la variable donde se almacenará la entrada válida.
    #         - Nota: Debe ser el nombre de una variable y no su valor.
    #         - Ejemplo: `nombre`
    #     $3: Número mínimo de caracteres requeridos para validar la entrada.
    #         - Ejemplo: `3`
    #
    # Comportamiento:
    #     - Solicita repetidamente la entrada del usuario hasta que cumpla con el número mínimo de caracteres.
    #     - Una vez validada, almacena la entrada en la variable especificada en el argumento `$2`.
    #
    # Comandos Utilizados:
    #     read: Solicita una entrada del usuario desde la línea de comandos.
    #     eval: Evalúa y asigna el valor de la entrada validada a la variable especificada.
    #     ${#var}: Obtiene la longitud del texto almacenado en una variable.
    #
    # Salida:
    #     - Si la entrada es válida, la función termina y la variable especificada contiene el valor ingresado.
    #     - Si la entrada no es válida, muestra un mensaje de error y repite el prompt.
    #
    # Ejemplo de uso:
    #     nombre=""
    #     input_min_chars "Introduce tu nombre: " nombre 3
    #     echo "Hola, $nombre."
    #
    # Ejemplo:
    #     Introduce tu nombre: Jo
    #     Por favor, ingresa al menos 3 caracteres.
    #     Introduce tu nombre: John
    #     Hola, John.

    local mensaje=$1
    local variable=$2
    local chars_min=$3

    while true; do
        read -p "$mensaje" input
        if [[ ${#input} -ge $chars_min ]]; then
            eval "$variable='$input'"
            break
        else
            echo "Por favor, ingresa al menos $chars_min caracteres."
        fi
    done
}

input_opciones() {
    # Solicita al usuario una entrada de texto seleccionada entre un conjunto de opciones válidas.
    #
    # Argumentos:
    #     $1: Mensaje a mostrar al usuario como prompt.
    #         - Ejemplo: "Selecciona una opción"
    #     $2: Opciones válidas separadas por espacios.
    #         - Ejemplo: "sí no tal_vez"
    #     $3: (Opcional) Opción por defecto que se usará si el usuario presiona Enter sin escribir nada.
    #         - Si no se proporciona, se tomará la primera opción del argumento $2 como predeterminada.
    #         - Ejemplo: "sí"
    #
    # Comportamiento:
    #     - Muestra un prompt con las opciones separadas por `/` y la opción predeterminada.
    #     - Valida que la entrada sea una de las opciones permitidas.
    #     - Si el usuario no ingresa nada, retorna la opción por defecto.
    #     - Si la entrada no es válida, muestra un mensaje de error y repite el prompt.
    #
    # Comandos Utilizados:
    #     IFS: Define el delimitador de campo para dividir cadenas.
    #     read: Solicita una entrada del usuario desde la línea de comandos.
    #     [[ " ${array[@]} " =~ " $value " ]]: Valida si un valor está en un array.
    #
    # Notas:
    #     - Si las opciones contienen caracteres especiales, pueden necesitar ser escapadas.

    local mensaje=$1
    local opciones_string=$2
    local por_defecto=${3:-$(echo $opciones_string | awk '{print $1}')}

    IFS=' ' read -r -a opciones <<<"$opciones_string"

    local opciones_separadas
    IFS='/' opciones_separadas="${opciones[*]}"

    while true; do
        local prompt="$mensaje ($opciones_separadas) [default:$por_defecto]: "
        read -p "$prompt" input

        if [[ -z $input ]]; then
            echo "$por_defecto"
            return
        elif [[ " ${opciones[@]} " =~ " $input " ]]; then
            echo "$input"
            return
        else
            echo "Entrada no válida."
        fi
    done
}
