#!/bin/bash

#Rafael Alejandro Díaz Rangel

echo "Bienvenido"
echo "Mostrando interfaces de red disponibles..."
ip link show

echo "¿Por cuál interfaz deseas conectarte?"
read interface

# Obtener la primera letra para determinar el tipo de conexión
primer_letra=${interface:0:1}

# Verificar si es WiFi o Interfaz Cableada
if [[ "$primer_letra" == "w" ]]; then
    echo "Has ingresado una interfaz WiFi: $interface"
elif [[ "$primer_letra" == "e" ]]; then
    echo "Has ingresado una interfaz cableada: $interface"
else
    echo "Interfaz desconocida: $interface"
    exit 1
fi

# Activar la interfaz
sudo ip link set dev "$interface" up

# Si es una interfaz WiFi
if [[ "$primer_letra" == "w" ]]; then
    echo "Cargando redes disponibles..."
    sudo iw "$interface" scan | grep "SSID:"

    echo "Ingresa el SSID al cual deseas conectarte:"
    read SSID

    echo "¿El SSID tiene seguridad? (Y/n)"
    read opcion

    if [[ "$opcion" == "Y" ]]; then
        echo "Ingresa la contraseña:"
        read -s password
        sudo nmcli dev wifi connect "$SSID" password "$password"
    else
        sudo nmcli dev wifi connect "$SSID"
    fi

    echo "Configuración de WiFi guardada de forma permanente."

# Si es una interfaz cableada
elif [[ "$primer_letra" == "e" ]]; then
    echo "Selecciona el tipo de configuración de red:"
    echo "¿Estática o Dinámica? (e/d)"
    read opcion

    if [[ "$opcion" == "e" ]]; then
        echo "Introduce la dirección IP:"
        read ip
        echo "Introduce la máscara de red:"
        read mascara
        echo "Introduce la puerta de enlace:"
        read gateway

        # Configuración estática
        sudo nmcli connection add type ethernet ifname "$interface" ip4 "$ip/$mascara" gw4 "$gateway"
        sudo nmcli connection modify "$interface" ipv4.method manual
        sudo nmcli connection up "$interface"
	# nmcli ya hace el guardado en automatico.
        echo "Configuración estática aplicada y guardada."

    elif [[ "$opcion" == "d" ]]; then
        # Configuración dinámica (DHCP)
        sudo nmcli connection add type ethernet ifname "$interface"
        sudo nmcli connection modify "$interface" ipv4.method auto
        sudo nmcli connection up "$interface"
        echo "Configuración dinámica (DHCP) aplicada y guardada."
    fi
fi

# Verificar conexión
echo "Verificando conexión..."
ping -c 4 8.8.8.8

if [ $? -eq 0 ]; then
    echo "Conexión exitosa."
else
    echo "No se pudo establecer la conexión."
fi
