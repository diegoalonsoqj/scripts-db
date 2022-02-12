#!/bin/bash

# nombreBD_BK-yearMonthDay-horaMinutoSegundo
# Crear carpeta BACKUPS en la Raiz y en ella la carpeta mysql.
# mkdir -p /BACKUPS/MySQL


# Carpeta destino 
DEST=/BACKUPS/MySQL/


## Banner
echo ""
echo " *** BACKUP MYSQL ***"


## Config mysql
HOST="localhost"
#USER="userMysql"
#PASS="passwordMysql"
#db="databaseMysql"


## Ingresar Datos MySQL
read -p "- Ingresar Usuario: " USER
STTY_SAVE=`stty -g`
stty -echo
read -p "- Ingrese Password: " PASS
stty $STTY_SAVE
echo
read -p "- Ingrese Base de Datos: " db
read -p "- Verbosidad (s/n): " verb


# Variables
Fecha=$(date +"%Y%m%d")
Hora=$(date +"%H%M%S")
File=$db"_BK-"
fileExt=".sql.gz"
guion="-"
finalFile=$File$Fecha$guion$Hora$fileExt


## Ejecucion
timeInit=$(date +"%T - %d/%m/%Y")
cd $DEST

case $verb in
  s)
    echo ""
    mysqldump --single-transaction --routines --quick -h $HOST -u $USER -p$PASS -B $db --verbose | gzip > $finalFile
    sleep 3
    #clear
  ;;
  n)
    mysqldump --single-transaction --routines --quick -h $HOST -u $USER -p$PASS -B $db | gzip > $finalFile
  ;;
  *)
    echo "No es una opcion valida."
  ;;
esac

timeFin=$(date +"%T - %d/%m/%Y")
pesoFile=$(du -h $finalFile | cut -f1)


## Imprimir resultado
echo ""
echo ""
echo " *** BACKUP TERMINADO ***"
echo "- Inicio: " $timeInit
echo "- Fin   : " $timeFin
echo "- Peso  : " $pesoFile
echo "- File  : " $finalFile
echo "- Ruta  : " $DEST$finalFile
echo ""


echo "###  Backups Disponibles  ###"
tree $DEST