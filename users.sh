source user_func.sh

for usuario in "${usuarios[@]}"; do
    crear_usuario_linux $usuario
    crear_usuario_samba $usuario
    agregar_a_grupo "trebol" $usuario
    sector=$()

done
