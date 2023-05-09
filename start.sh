#!/bin/bash
# Obligatorio 1 de Taller de Tecnologias
# Nombres aca.

# Main Loop Function.
function menuPrincipal {
    echo "Bienvenido!"
    echo " "
    echo "1) Ingresar Usuario y Contraseña"
    echo "2) Ingresar al sistema."
    echo "3) Salir del Sistema."
    echo " "
    read -p "Ingrese una opción: " option

    case $option in
        1)
            addUser
            ;;
        2)
            login
            ;;
        3)
            clear
            exit 
            ;;
        *)
            echo "Opción inválida..."
            sleep 1
            clear
            menuPrincipal
            ;;
    esac
}

# Set New User main menu function.
function addUser {
    echo " "
    read -p "Ingrese un nombre de usuario: " user

    while [ $(grep -i -c  "^$user" users.txt) != "0" ]; 
    do
        echo "El usuario $user, ya existe. Pruebe con otro usuario."
        sleep 1
        read -p "Ingrese un nombre de usuario: " user
        ocurrencias=$(grep -i -c  "^$user" users.txt)
    done
    
    read -p "Ingrese una contraseña: " pass
    timestamp=$(date +%s);
    echo "$user:$pass:$timestamp" >> users.txt
    echo " "
    echo "Usuario $user creado exitosamente"
    sleep 2
    clear
    menuPrincipal
}

# Login Function, Reads an user and a pass and tries to authenticate through.
function login {
    read -p "Ingrese su nombre de usuario: " user
    read -p "Ingrese su contraseña: " pass

    if [ $(grep -c "^$user:$pass:" users.txt) = "1" ] 
    then
        # Get Older Timestamp and update it with the new one.
        updateLastSeen $user $pass
        
        letter="a"  
        menuLogged
    else
        # Usuario y/o contraseña inválidos
        echo "Usuario y/o contraseña inválidos"
        sleep 2
        clear
        login
    fi
}

# Change Password Main Function
# Params user
function changePass {
    # Get the current Pass from the authenticated user.
    actualpass= read -p "Ingrese contraseña actual del usuario $1 "

    # Load the user password into function.
    currentPassword= getUserPassword $1

    # Check both.
    if [[ $actualpass == $currentPassword ]]
    then
        read -p "Ingrese contraseña nueva para $1  " newpass

        if [[ $1 == $currentPassword ]]
        then 
            # For any cases that the user is equal to the pass...
             sed -i "s/$1\:$(getUserPassword $1)/$1\:$newpass/2" users.txt
        else
            # Regular pass change.
             sed -i "s/$1\:$(getUserPassword $1)/$1\:$newpass/" users.txt
        fi

        # Echo message and wait for a few secs.
        echo "La contraseña ha sido actualizada!"
        sleep 2
        clear
    else
        # Try Again.
        echo "La contraseña no coincide con la del usuario $1, intente nuevamente... "
        sleep 2
        changePass $1
    fi

    menuLogged
}

# Getter for User Password
# Returns string
function getUserPassword() {
    grep -i "^$1:" users.txt | cut -d ":" -f2
}

# TODO: Document this?
function wordCounter() {
  local letra=$1  
  local diccionario=$2  

  local cantidad=$(grep -c "$letra$" "$diccionario")
  
  echo "$cantidad" 
}

# Timestamp Function, Get the last seen.
# Params user
# Returns Timestamp.
function getLastSeen() {
    grep "^$1:" users.txt | cut -d ":" -f3
}

# Updates LastSeen for user
# Params user, password
function updateLastSeen() {
    # Calculate Timestamp
    timestamp=$(date +%s);

    # Replace the timestamp 
    sed -i "s/$(getLastSeen $1 $2)/$timestamp/" users.txt
}

# Helper Function reads a letter and stores it.
function readletter {
    clear
    read -p "Ingrese una letra para almacenar " letter
    sleep 1
    clear
    menuLogged $letter
}

# This function as as the main menu after login in.
function menuLogged() {
    clear
    echo "Bienvenido $user"
    lastSeen=$(getLastSeen $user)
    echo "Usted ingresó por última vez el dia $(date +'%Y-%m-%d a las %H:%M:%S' -d "@$lastSeen")"
    echo " "
    echo "------MENU PRINCIPAL-----"
    echo "1) Cambiar Contraseña."

    if [ -z $1 ];
    then echo "2) Escoger una letra."
    else echo "2) Escoger otra letra. Letra actual: $1" 
    fi

    echo "3) Buscar palabras en el diccionario que finalicen con la letra escogida."
    echo "4) Contar las palabras de la Opción 3."
    echo "5) Guardar las palabras en un archivo.txt, en conjunto con la fecha y hora de realizado el informe."
    echo "6) Volver al Menú Principal."
    echo " "
    read -p "Ingrese una opción: " option

     case $option in
        1)
            changePass $user
            ;;
        2)
            readletter
            ;;
        3)
            # Buscar en diccionario.txt
            ;;
        4)
            letra= letter
            diccionario= "diccionario.txt"

            countedWords = $(wordCounter "$letra" "$diccionario") 

            echo "Hay $countedWords palabras que terminan en '$letra' en el diccionario." #averiguar si importan mayusculas

            ;;
        5)
            ;;
        6)  menu_principal
            ;;
        *) echo "Opcion Invalida."
            menuLogged
            ;;
     esac
}

# Main Menu loop.
while true
do
    menuPrincipal
done