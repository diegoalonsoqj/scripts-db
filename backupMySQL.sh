#!/bin/bash

# Requisitos para el correcto funcionamiento:
#00 04 * * * /opt/scriptsDQJ/backupMySQL.sh
#mkdir -p /tempBackup/mysql
#mkdir -p /RESPALDOS/DB_MYSQL

# Carpeta destino 
DEST=/tempBackup/mysql
dirDrive=/RESPALDOS/DB_MYSQL
CURRDATE=$(date +"%F")

# config mysql
USER="USUARIO MYSQL"
PASS="PASSWORD USUARIO MYSQL"

Fecha=$(date +"%d%m%Y")
anteAyerFecha=$(date +"%d%m%Y" --date='-2 day')
dirFecha="-"$Fecha
dirDBs="databases"
dirDBFinal=$dirDBs$dirFecha
fileExtComp=".tar.gz"

nameCliente="AQUI EL NOMBRE DEL CLIENTE"
hostCliente="URL DEL HOST"
correoReceptor="EMAIL RECEPTOR DE ALERTAS"

timeInit=$(date +"%T - %d/%m/%Y")

DATABASES=$(mysql -u $USER -p$PASS -e "SHOW DATABASES;" | tr -d "| " | grep -v Database)

[ ! -d $DEST ] && mkdir -p $DEST

for db in $DATABASES; do
  FILE="${DEST}/$db.sql.gz"
  FILEDATE=

  [ -f $FILE ] && FILEDATE=$(date -r $FILE +"%F")
  [ "$FILEDATE" == "$CURRDATE" ] && continue

  [ -f $FILE ] && mv "$FILE" "${FILE}.old"
  mysqldump --single-transaction --routines --quick -u $USER -p$PASS -B $db | gzip > "$FILE"
  rm -f "${FILE}.old"
done

timeFin=$(date +"%T - %d/%m/%Y")

cd $DEST
mkdir -p $dirDBFinal
mv *.sql.gz $dirDBFinal/
tar -czvf $dirDBFinal$fileExtComp $dirDBFinal
rm -rf $dirDBFinal
mkdir -p pesoBackup
mv $dirDBFinal$fileExtComp pesoBackup/
cd pesoBackup/
pesoBK=$(du -hs)
mv $dirDBFinal$fileExtComp ../
cd $DEST
rm -rf pesoBackup/
mv $dirDBFinal$fileExtComp $dirDrive
cd $dirDrive
rm -rf $dirDBs"-"$anteAyerFecha$fileExtComp

### ALERTA POR CORREO
fechaEmail=$(date +"%Y%m%d%H%M%S")
echo -e "    ###  BACKUP DB_MYSQL  ###  \n\n - Cliente: " $nameCliente "\n - Host: " $hostCliente "\n - Inicio: " $timeInit "\n - Fin:     " $timeFin "\n - Peso Bakcup: " $pesoBK | mail -s "BACKUP MYSQL "$fechaEmail $correoReceptor

