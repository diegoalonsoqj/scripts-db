#!/bin/bash

# nombreBD_BK-yearMonthDay-horaMinutoSegundo
# Crear carpeta BACKUPS en la Raiz y en ella la carpeta mysql.
# mkdir -p /BACKUPS/PostgreSQL

# Carpeta destino 
DEST=/BACKUPS/PostgreSQL/

## Banner
echo ""
echo " *** BACKUP POSTGRESQL ***"

## Config Postgresql
HOST="localhost"


## Ingresar Datos PostgreSQL
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
    pg_dump -h $HOST -U $USER -W $PASS -d $db -v > $finalFile
    sleep 3
  ;;
  n)
    echo ""
    pg_dump -h $HOST -U $USER -W $PASS -d $db > $finalFile
    sleep 3
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

tree $DEST