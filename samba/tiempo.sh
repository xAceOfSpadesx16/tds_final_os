source trebol.conf
source utils.sh

echo "Definiendo propietario para ntp_signd..."
sudo chown root:_chrony "$NTPSIGND_PATH"

echo

echo "Definiendo permisos para ntp_signd..."
sudo chmod 750 "$NTPSIGND_PATH"

echo

echo "Modificando archivo /etc/chrony.conf..."
sudo tee -a /etc/chrony.conf >/dev/null <<EOF
bindcmdaddress $(obtener_ip)
allow $(obtener_red)
ntpsigndsocket $NTPSIGND_PATH
EOF

echo

echo "Reiniciando el servicio chronyd..."
sudo systemctl restart chronyd

echo

echo "Verificando el estado del servicio..."
sudo systemctl status chronyd --no-pager

echo
