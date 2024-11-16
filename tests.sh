#!/bin/bash
# Agrega un "sleep 1" después de cada comando ejecutado
trap 'sleep 1' DEBUG

# Comandos del script
echo "Primer comando"
ls /tmp
echo "Segundo comando"
ls ~/
echo "Tercer comando"
