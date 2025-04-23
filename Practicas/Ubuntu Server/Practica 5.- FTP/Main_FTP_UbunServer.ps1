source funciones_FTP.sh

instalar_ftp
alojar_puerto_ftp
config_vsftpd
crear_grupos
acceso_anonimo

OPCION=-1

while [ "$OPCION" -ne 0 ]; do
    echo "elija opcion a realizar"
    echo "1. Crear un nuevo usuario"
    echo "2. Cambiar de grupo"
    echo "0. Salir"
    read -p "elija una opción: " OPCION

    case "$OPCION" in
        1)  
            read -p "Ingrese el usuario: " USUAIRO
            read -p "Ingrese la contraseña: " CONTRASEÑA

            while true; do
                read -p "Asignele un grupo al usuario creado (reprobados/recursadores): " GRUPO

                if [ "$GRUPO" = "reprobados" ] || [ "$GROUP" = "recursadores" ]; then
                    create_user "$USUARIO" "$CONTRASEÑA" "$GRUPO"
                    break  
                else
                    echo "Grupo no válido. Debe ser 'reprobados' o 'recursadores'."
                fi
            done
            ;;
        
        2)  
            echo "Cambiando de grupo"
            user_group_info=$(get_user_and_group) 
            username=$(echo "$user_group_info" | awk '{print $1}') 
            new_group=$(echo "$user_group_info" | awk '{print $2}') 

            change_user_group "$username" "$new_group"
            ;;
        0)  
            echo "Saliendo."
            exit 0
            ;;
        *)  
            echo "Opción no válida. Intente nuevamente."
            ;;
    esac
done