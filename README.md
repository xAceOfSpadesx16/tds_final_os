# <center>Trabajo Integrador Final</center>
## <u>Asignaturas</u>:
- <b>Sistemas Operativos.</b>
- <b>Introduccion a las Redes de Datos.</b>

## <u>Alumnos</u>:
- <b>Andrés Ezequiel FONTANA</b>.
- <b>Marcos Adolfo TEVES</b>.

## <u>Profesor:</u>
- <b>Walter PIRCHIO</b>.

## <u>Problematica:</u>
<i>Estructura de Directorios y Usuarios basados en problematica de Trebol S.A.</i>

## <u>Requerimientos</u>:
- Sistema Operativo - Linux con gestor de paquetes APT.
- Disco Rigido en blanco o disponible para formatear completamente.
- Espacio minimo requerido por defecto: 30GB.
    - 10GB para home.
    - 5GB para ventas.
    - 5GB para contabilidad.
    - 10GB para otros.

## <u>Objetivos del Trabajo</u>:
<p style='text-align: justify;'>El trabajo tiene como principal objetivo la creacion y configuracion automatica y desde cero de un Active Directory Domain Controller con Samba y el correspondiente provisionamiento de dominio, haciendo especial enfasis en el dinamismo de la creacion de recursos compartidos y particiones donde seran montados estos recursos.</p>
<p style='text-align: justify;'>Este dinamismo esta dado gracias al archivo trebol.conf donde se encuentran definidas las variables necesarias para la ejecución del script y gracias a la posibilidad de definir nuevos listados de personal o modificar los existentes, dando lugar a la creacion de nuevas areas de trabajo con sus respectivos usuarios, recursos compartidos y particiones.</p>

## <u>Modo de Ejecución</u>
- Clonar el presente repositorio en el directorio deseado.
    - git clone https://github.com/xAceOfSpadesx16/tds_final_os.git
- Ingresar directorio raiz del repositorio y ejecutar el comando:
    - sudo bash init.sh

## <center> <u> Flujo de ejecución </u> <center>

El flujo de ejecucion del presente proyecto esta dado por el archivo init.sh alojado en la raiz del repositorio, los pasos que éste realiza son:

- <b> Creación de Estructura de Directorios y Copiado de archivos requeridos. </b>
    - Copiado de contenido de skel a /etc/smb_skel.
    
    - Creacion de directorios definidos en configuracion.
        - /etc/trebol
        - /etc/trebol/sectores
        - /var/trebol
        - /var/trebol/home
        - /var/trebol/otros

    - Copia de listados de personal a /etc/trebol/sectores.

    - Creacion de directorios de areas de trabajo.

- <b> Verificación de disco definido a los fines de corroborar que se encuentre en condiciones de ser formateado. </b>

    - Obtencion de directorios y tamaños de particiones a montar.

    - Verificacion de existencia de disco.

    - Verificacion de dispositivo de bloque.

    - Calculo de espacio requerido.

    - Verificacion de espacio disponible.

    - Verificacion de particiones existentes.

    - Solicitud de confirmacion de sobrescritura de particiones existentes.
    
- <b> Verificación de Paquetes requeridos y su instalación. </b>

    - Obtencion de paquetes requeridos no instalados.

    - En caso de paquetes faltantes, se solicita confirmacion de instalacion de paquetes:
        - Actualizacion de listado de repositorios.
        - Definicion de entradas requeridas en instalacion de Kerberos.
        - Instalacion de Kerberos 5.
        - Instalacion de restantes paquetes requeridos.
        - En caso de negativa de instalacion, es cancelada la ejecucion del script.

- <b> Preparacion de hostname y resolución de nombres. </b>

    - Obtencion de ip acorde a adaptador definido.

    - Definicion de hostname.

    - Remocion de linea "127.0.1.1 dc" de /etc/hosts en caso de existir.

    - Definicion de resolucion de nombres local en /etc/hosts.

    - Verificacion de FQDN (Fully Qualified Domain Name).

    - Ping a FQDN.

    - Deshabilitacion de servicio systemd-resolved.

    - Eliminacion de enlace simbolico de /etc/resolv.conf.

    - Creacion de nuevo archivo resolv.conf.

    - Definicion de inmutabilidad en archivo resolv.conf.

- <b> Formateo y Particionado de Disco. </b>

    - Creacion de tabla de particiones MSDOS.

    - Creacion de particion extendida del 100% del espacio.

    - Creacion de particiones logicas dinamicamente.

    - Formateo de particiones logicas con File System EXT4.

- <b> Montaje de Particiones. </b>

    - Inclusion de puntos de montaje en /etc/fstab.

    - Recarga de systemd con daemon-reload para reconocer cambios en fstab.

    - Montaje de todas las particiones.

- <b> Configuracion de Samba </b>

    - Inhabilitacion de servicios smbd, nmdb y winbind.

    - Desenmascarado y Habilitacion de servicio samba-ad-dc.

    - Backup de archivo /etc/samba/smb.conf.

    - Provision de Dominio con entrada interactiva.

    - Backup de archivo /etc/krb5.conf.

    - Sustitucion de archivo /etc/krb5.conf por /var/lib/samba/private/krb5.conf.

    - inicio y verificación de status de servicio samba-ad-dc.

- <b> Configuracion de Sincronizacion de Tiempo </b>

    - Definicion de propietarios y permisos de /var/lib/samba/ntp_signd

    - Modificacion de archivo /etc/chrony.conf
        - bindcmdaddress: Especifica la dirección IP y el puerto en los que escuchará el demonio Chrony para recibir comandos de administración.
        - allow: Define una lista de control de acceso (ACL) que determina qué hosts o redes pueden conectarse al servidor Chrony como clientes NTP.
        - ntpsigndsocket: Especifica la ubicación del socket Unix utilizado para la firma digital de paquetes NTP.

    - Reinicio y verificacion de servicio chronyd.


- <b> Creación de grupos </b>

    - Creación de grupo principal (trebol).

    - Creación de grupo de administracion (admin_gral).

    - Creación de grupos de areas de trabajo (contabilidad y ventas).

    - Estos grupos se crean en base a listas de personal definidas en /etc/trebol/sectores.
        - trebol.list contiene a todos los usuarios de la empresa.
        - admin_gral.list contiene a los administradores de la empresa.
        - contabilidad.list contiene a los usuarios del area de contabilidad.
        - ventas.list contiene a los usuarios del area de ventas.

- <b> Creación de usuarios en Samba </b>
    - Obtencion de lista de personal de trebol.list.

    - Creacion del usuario:
        - Obtencion de contraseña alfanumerica de 8 caracteres aleatorios mediante /dev/urandom y comandos tr, fold, grep y head.

        - Creacion de usuario mediante samba-tool user create.

        - Guardado de contraseña en archivo /etc/trebol/demo_samba_users.txt para fines de demostración.
    
    - Asignacion de grupo acorde a listas de personal.

    - Creacion de directorio Home para el usuario.
        - Creacion de directorio Home en /var/trebol/home.
        - Definicion de propietarios del Home (DOMAIN\user y grupo administrador de sistema para fines de demostración).
    
    - Copiado de contenido de /etc/smb_skel a Home del usuario.

    - Definicion de propietarios y permisos de Home y su contenido.

- <b> Definicion de propietarios y permisos de estructura de directorios. </b>

    - Definicion de propietarios y permisos de directorios creados en primer script ejecutado.
        - /etc/trebol
        - /etc/trebol/sectores
        - /var/trebol
        - /var/trebol/home
    
    - Definicion de propietarios y permisos de areas de trabajo.
        - /var/trebol/ventas
        - /var/trebol/contabilidad

- <b> Definicion de recursos compartidos. </b>

    - Definicion de recurso compartido [homes].
        - comment = Directorios personales
        - path = /var/trebol/home/%S
        - browseable = no
        - read only = no
        - valid users = %S
        - create mask = 640
        - directory mask = 2750

    - Definicion de recursos compartidos [ventas] y [contabilidad].
        - path = /var/trebol/{ventas,contabilidad}
        - read only = no
        - browseable = yes
        - valid users = mgarcia, @{ventas,contabilidad}
        - write list = mgarcia
        - create mask = 640
        - directory mask = 2750
        - comment = Area de trabajo: {ventas,contabilidad}


- <b> Creación de archivo de configuración </b>

    - Creacion de archivo /etc/trebol/trebol.conf.

    - Insercion de variables a utilizar por scripts.
        - addsambauser
        - addshared


- <b> Definicion de scripts de creacion de usuarios y creacion de recursos compartidos: </b>

    - Creación manual de usuario de Samba con seleccion de area de trabajo.
        - Movimiento de archivo en /usr/bin/trebol_user.sh.
        - Definicion de permiso de ejecucion.
        - Definicion de alias en /home/$SYSTEM_ADMIN_USER/.bash_aliases.

    - Creación manual de Recurso Compartido.
        - Movimiento de archivo en /usr/bin/trebol_share.sh.
        - Definicion de permiso de ejecucion.
        - Definicion de alias en /home/$SYSTEM_ADMIN_USER/.bash_aliases.