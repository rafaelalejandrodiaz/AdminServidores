#!/bin/bash

echo "BIENVENIDO AL MANEJADOR DE USUARIOS!"
echo "Introduce el nombre del usuario que deseas crear: "
read usuario
echo "Deseas que el usuario tenga un directorio '/home' (Y/n)"?
read opcion

echo "Ingresa la contraseña para el usuario: "
read -s contrasena
echo "Vuelve a ingresar la contraseña para confirmar: "
read -s contrasena_dos

if test ! "$contrasena" = "$contrasena_dos"
then
	echo "Las contraseñas no coinciden..."
	exit 1
else
	echo "Las contraseñas coinciden!"
fi

case $opcion in
	"Y" | "y")
	echo -n "Creando usuario..."
	sleep 5
	sudo useradd -m "$usuario"
	echo "finalizado."
	;;

	"N" | "n")
	echo -n "Creando usuario sin directorio..."
	sleep 5
	sudo useradd "$usuario"
	echo "finalizado."
	;;

	*)
	echo -n "Opción Invalida."
	exit 1;
	;;
esac

echo "Configurando contraseña..."
sudo apt-get install -y expect > /dev/null 2>&1
expect <<EOF
spawn sudo passwd "$usuario"
expect "Nueva contraseña:"
send "$contrasena\r"
expect "Vuelva a escribir la nueva contraseña:"
send "$contrasena\r"
expect eof
EOF

echo "Contraseña asignada correctamente."

echo "Deseas agregar al usuario a un grupo en especifico(Y/n)?"
read opcion_dos

if test "$opcion_dos" = "Y" || test "$opcion_dos" = "y"
then
	echo "Ingresa al grupo al cual lo deseas agregar: "
	read grupo
	sudo usermod -G $grupo $usuario
fi

echo "Deseas que el usuario tenga un UID en especifico(Y/n)?"
read opcion_tres

if test "$opcion_tres" = "Y" || test "$opcion_tres" = "y"
then
	echo "Ingresa el UID: "
	read uid_user
	sudo usermod -u $uid_user $usuario
fi

echo "Deseas configurar una fecha de expiración(Y/n): "
read opcion_cuatro

if test "$opcion_cuatro" = "V" || test "$opcion_cuatro" = "v"
then
	echo "Ingresa la fecha en formato 'AAAA-MM-DD':"
	read fecha_user
	sudo chage -E "$fecha_user" $usuario
fi

echo "Usuario $usuario creado exitosamente."
