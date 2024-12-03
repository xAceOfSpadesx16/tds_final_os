#!/bin/bash

# Descripción:
#     Este script deshabilita y detiene los servicios no necesarios para el servidor de Active Directory de Samba
#     (como `smbd`, `nmbd` y `winbind`), y habilita el servicio `samba-ad-dc` para que funcione como controlador
#     de dominio Active Directory.
#
# Comandos Utilizados:
#     sudo systemctl disable: deshabilita un servicio para que no se inicie automáticamente al arrancar el sistema.
#         opciones:
#             - --now: detiene el servicio inmediatamente además de deshabilitarlo.
#     sudo systemctl unmask: desenmascara o elimina la máscara de un servicio, permitiendo que se pueda iniciar.
#     sudo systemctl enable: habilita un servicio para que se inicie automáticamente al arrancar el sistema.
#

# Detiene y deshabilita los servicios que el servidor de Active Directory de Samba no requiere (smbd, nmbd y winbind)
sudo systemctl disable --now smbd nmbd winbind

# Habilita samba-ac-dc para funcionar como Active Directory y controlador de dominio.
sudo systemctl unmask samba-ad-dc
sudo systemctl enable samba-ad-dc
