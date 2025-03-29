#!/bin/bash

function crear_usuario(){

	command="useradd"

	echo "Escribe el nombre del usuario: "
	read username
	echo "Escribe la contraseña para el usuario: "
	read -s password_one
	echo "Escribe la contraseña nuevamente:"
	read -s password_two

	if test "$password_one" != "$password_two";
	then
		echo "ERROR."
		echo "Las contraseña no coinciden..."
		exit 1
	else
		echo "Las contraseñas coinciden!"
	fi

	echo "¿Deseas crear al usuario con un directorio(/home/user)? [S/n]" 
	read opcion_uno

	if test "$opcion_uno" = "S" || test "$opcion_uno" = "s"; 
	then 
		echo "Ingresa el directorio: "
		read dir_user
		if test ! -d "$dir_user";
		then
			echo "ERROR."
			echo "No has ingresado un directorio..."
			exit 1
		else
			command="$command -d \"$dir_user\""
		fi
	fi
	
	echo "¿Deseas que el usuario tenga un directorio /home? [S/n]"
	read opcion_dos

	if test "$opcion_dos" = "S" || test "$opcion_dos" = "s";
	then
		command="$command -m"
	fi 

	echo "¿Deseas agregar directorio esqueleto al usuario? [S/n]"
	read opcion_tres

	if test "$opcion_tres" = "S" || test "$opcion_tres" = "s"; 
	then
		echo "Ingresa el directorio esqueleto que desear agregar al usuario: "
		read dir_skelet
		if test ! -d "$dir_skelet";
		then
			echo "ERROR"
			echo "No has ingresado un directorio..."
			exit 1
		else
			command="$command -k \"$dir_skelet\""
		fi
	fi

	echo "¿Deseas agregar un shell especifico al usuario? [S/n]"
	read opcion_cuatro

	if test "$opcion_cuatro" = "S" || test "$opcion_cuatro" = "s"; 
	then
		echo "Ingresa el shell que deseas configurar para el usuario (ejemplo: /bin/bash): "
		read bash_user_dir
		command="$command -s \"$bash_user_dir\""
	fi

	echo "¿Deseas agregar el usuario a algun grupo? [S/n]"
	read opcion_cinco


	if test "$opcion_cinco" = "S" || test "$opcion_cinco" = "s"; 
	then
		echo "Ingresa la ruta del grupo: "
		read user_group_dir
		command="$command -g \"$user_group_dir\""
	fi

	command="$command $username"

	echo "¿Estas seguro de crear al usuario? [S/n]"
	read opcion_seis
	
	if test "$opcion_seis" = "S" || test "$opcion_seis" = "s"; 
	then
		eval "$command" && echo "$username:$password_one" | chpasswd
	else
		echo "El usuario no ha sido creado..."
		exit 0
	fi

	echo "El usuario ha sido creado exitosamente..."
	exit 0
}

function cuotas_usuario(){
	echo "Gestor de cuotas..."
	echo "En caso de venir de reniciar el sistema teclee 'n' en la siguiente opción para poder continuar..."
	echo "Es la primera vez usando cuotas en el sistema? [S/n]:"
	read opcion_cuota_one
	if test "$opcion_cuota_one" = "S" || test "$opcion_cuota_one" = "s";
	then
	
		echo "Preparando el entorno de cuotas..."
		sudo apt install quota
		echo "Modifica el archivo de cuotas /etc/fstab"
		echo "En casos de asignar cuotas a usuarios(usrquota)."
		echo "En casos de asignar cuotas a grupos(grpquota)."
		echo "Modifica el archivo..."
		echo "¿Has modificado el archivo? [S/n]"
		read opcion_cuota_two
		if test "$opcion_cuota_two" = "S" || test "$opcion_cuota_two" = "s";
		then
			echo "Confirma que reniciaras el sistema [S/n]: "
			read confirmacion_reinicio

			if test "$confirmacion_reinicio" = "S" || test "$confirmacion_reinicio" = "s";
			then 
				echo "Procedermos a reinciar el sistema..."
				sudo reboot
			fi
			
		else
			echo "Cancelación de proceso..."
			exit 0
		fi			
	else
		echo "Ingresa al usuario al cual deseas asignarle cuotas: "
		read user_cuota

		if ! id "$user_cuota" &</dev/null; then
			echo "El usuario no existe."
			exit 1
		fi
		
		echo "Ingresa el limite soft para la cuota en kb: "
		read soft_limit_cuota
		echo "Ingresa el limite hard para la cuota en kb: "
		read hard_limit_cuota
		echo "Ingresa el numero de maximo de archivos(soft): "
		read soft_inodes_cuota
		echo "Ingresa el numero maximo de archivos(hard): "
		read hard_inodes_cuota
		echo "Ingresa el filesystem: "
		read filesystem_cuota

		command_cuota="setquota $user_cuota $soft_limit_cuota $hard_limit_cuota $soft_inodes_cuota $hard_inodes_cuota $filesystem_cuota"
		
		echo "Deseas estableces un periodo de gracia? [S/n]: "
		read opcion_cuota_three
		if test "$opcion_cuota_three" = "S" || test "$opcion_cuota_three" = "s";
		then
			echo "Establece un soft time en segundos: "
			read soft_time
			echo "Establce un hard time en segundos: "
			read hard_time
			command_cuota="$command_cuota -t $soft_time $hard_time"
		fi

		echo "Configuración de cuotas finalizada..."
		echo "Procesando..."
		eval $command_cuota
		if test $? -eq 0;
		then
			echo "Cuota establecida correctamente."
		else
			echo "Error al estableces la cuota."
		fi

		echo "Comando ejecutado:  $command_cuota"
		
	fi 
	
}

function control_comandos {
    echo "Gestor de comandos"
    echo "Ingresa el nombre del usuario: "
    read usuario_comandos
    
    echo "Deseas agregar el usuario a sudo? [S/n]"
    read opcion_control_uno
    
    if [[ "$opcion_control_uno" == "S" || "$opcion_control_uno" == "s" ]];
    then
        echo "Agregando usuario a sudo..."

        if id "$usuario_comandos" &>/dev/null; 
        then
            usermod -aG sudo "$usuario_comandos"
            echo "El usuario '$usuario_comandos' ha sido agregado al grupo sudo."
        else
            echo "El usuario '$usuario_comandos' no existe. Por favor, crea el usuario primero."
        fi
    fi
    
    echo "¿Quieres asignar permisos específicos de sudo para este usuario? [S/n]"
    read opcion_control_dos

    if [[ "$opcion_control_dos" == "S" || "$opcion_control_dos" == "s" ]]; then
        echo "Especifica los comandos que el usuario '$usuario_comandos' podrá ejecutar (separados por comas):"
        read comandos_sudo
    
        echo "¿El usuario puede ejecutarlos sin contraseña? [S/n]"
        read opcion_sin_password
    
        if [[ "$opcion_sin_password" == "S" || "$opcion_sin_password" == "s" ]]; then
            comandos_sudo="NOPASSWD: $comandos_sudo"  # Agrega etiqueta para omitir contraseña
        fi
    
        echo "$usuario_comandos ALL=(ALL) $comandos_sudo" | sudo EDITOR='tee -a' visudo
        echo "Los comandos '$comandos_sudo' han sido asignados al usuario '$usuario_comandos'."
    fi
}


function main {
    echo "Bienvenido al gestor de usuarios..."
    echo "Opciones:"
    echo "1. Crear usuario."
    echo "2. Asignar cuotas."
    echo "3. Asignar permisos a usuario."
    read opcion_main_one

    case $opcion_main_one in
        1)
			crear_usuario        
            ;;
        2)
            cuotas_usuario
            ;;
        3)
            control_comandos
            ;;
        *)
            echo "Opción no válida."
            ;;
    esac

}

main
