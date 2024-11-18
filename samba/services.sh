#!/bin/bash

# Detiene y deshabilita los servicios que el servidor de Active Directory de Samba no requiere (smbd, nmbd y winbind)
sudo systemctl disable --now smbd nmbd winbind

# Habilita samba-ac-dc para funcionar como Active Directory y controlador de dominio.
sudo systemctl unmask samba-ad-dc
sudo systemctl enable samba-ad-dc
