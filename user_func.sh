generar_password_random() {
    # Comandos Utilizados:
    #     tr: realiza una traducción o eliminación de caracteres en una entrada. (filtrado)
    #     opciones:
    #         -d, --delete: elimina los caracteres que no esten especificados.
    #         -c, --complement: utiliza el conjunto de caracteres complementario (excluyendo el conjunto especificado).
    #     /dev/urandom: genera una secuencia de datos aleatorios.
    #     head: muestra las primeras líneas de un archivo o secuencia de entrada.
    #     opciones:
    #         -c, --bytes: limita la salida a un número específico de bytes.

    tr -dc 'A-Za-z0-9' </dev/urandom | head -c 6
}

crear_usuario_linux() {
    # Parametros:
    #     1) username
    # Comandos Utilizados:
    #     useradd: crea un nuevo usuario.
    #     opciones:
    #         -d, --home: especifica el path del directorio home del nuevo usuario.
    #         -m, --create-home: crea el directorio home del usuario.
    #         -U, --user-group: crea un grupo con el mismo nombre del usuario.
    #         -s, --shell: especifica el shell del usuario.
    #         -k, --skel: especifica un directorio de plantilla para el home del usuario.
    #    chpasswd: permite al administrador del sistema cambiar contraseñas de usuarios por lotes.

    username=$1
    password=$(generar_password_random)
    sudo useradd -d /var/trebol/home/$username -m -U -s /bin/bash -k /etc/skel $username
    sudo echo $username:$password | sudo chpasswd

    #registra los usuarios y contraseñas del sistema para fines didacticos
    echo -e "Usuario: $username\nContraseña: $password\n" >>~/demo_linux_users.txt
}

crear_usuario_samba() {
    # Parámetros:
    #     1) username
    # Comandos Utilizados:
    #     smbpasswd: administra contraseñas para usuarios Samba.
    #     opciones:
    #         -a: agrega un nuevo usuario a la base de datos de Samba.

    username=$1
    password=$(generar_random_password)
    (
        echo "$CONTRASENA_1"
        echo "$CONTRASENA_1"
    ) | sudo smbpasswd -a $USUARIO_1 >/dev/null 2>&1

    #registra los usuarios y contraseñas de la BBDD de Samba para fines didacticos
    echo -e "Usuario: $username\nContraseña: $password\n" >>~/demo_samba_users.txt

}

agregar_a_grupo() {
    group=$1
    username=$2
    sudo usermod -aG "$group" "$username"
}

filtrar_sector() {
    #utilizar grep o mapfile? esto recorriendo todos los archivos del directorio sectores.
}
