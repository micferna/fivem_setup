#/bin/bash -xe
source "src/functions.sh";

if [[ $EUID -ne 0 ]]; then
    clear
   echo -e "⛔ ${jaune}Lancer le script avec les droits (root ou sudo) ${neutre}" 
   exit 1
fi


while true 
do 
    clear 
    show_menu   
    read_input  
done 
