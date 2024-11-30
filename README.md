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

## <u>Objetivos del Trabajo</u>:
<p style='text-align: justify;'>El trabajo tiene como principal objetivo la creacion y configuracion automatica y desde cero de un Servidor de Samba Active Directory y el correspondiente provisionamiento de dominio, haciendo especial enfasis en el dinamismo de la creacion de recursos compartidos y particiones donde seran montados estos recursos.</p>
<p style='text-align: justify;'>Este dinamismo esta dado gracias al archivo trebol.conf donde se encuentran definidas las variables necesarias para todas las areas donde sea ejecutado el presente proyecto</p>

## <u>Modo de Ejecución</u>
- Clonar el presente repositorio en el directorio deseado.
    - git clone https://github.com/xAceOfSpadesx16/tds_final_os.git
- Ingresar directorio raiz del repositorio y ejecutar el comando:
    - sudo bash init.sh

## <u> Flujo de ejecución de Proyecto </u>

El flujo de ejecucion del presente proyecto esta dado por el archivo init.sh alojado en la raiz del repositorio, los pasos que éste realiza son:
- Creación de Estructura de Directorios y Copiado de archivos requeridos.
- Verificación de disco definido a los fines de corroborar que se encuentre en condiciones de ser formateado.
- Verificación de Paquetes requeridos y su instalación.
- Preparacion de hostname y resolución de nombres.
- Creación de nueva tabla de particiones MSDOS en el disco destinado al servidor, creación de una particion extendida y posterior definicion de particiones logicas dinamicamente.
- Definicion de puntos de montaje en archivo /etc/fstab y montaje de particiones.
- Inhabilitacion de servicios smbd, nmdb y winbind.
- Desenmascarado y Habilitacion de servicio samba-ad-dc.
- Backup de archivo /etc/samba/smb.conf.
- Provision de Dominio.
- Backup de archivo /etc/krb5.conf.
- Sustitucion de archivo /etc/krb5.conf por /var/lib/samba/private/krb5.conf.
- inicio y verificación de status de servicio samba-ad-dc.
- Sincronización de tiempo con NTP mediante Chrony.
- Creación de grupos dinamica, grupo principal (trebol), grupo de administracion (admin_gral) y areas de trabajo (contabilidad y ventas).
- Creación de usuarios en Samba, inclusion en grupos correspondientes y creacion de directorios Home incluyendo skel.
- Definicion de propietarios y permisos de estructura de directorios.
- Definicion de propietarios y permisos de areas de trabajo.
- Definicion de recursos compartidos homes y areas de trabajo dinamicamente.
- Inclusion de alias en archivo .bashrc del directorio home (administrador del servidor):
    - Creación manual de usuario de Samba con seleccion de area de trabajo.
    - Creación manual de Recurso Compartido. 