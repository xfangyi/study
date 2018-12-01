#!/bin/bash

jindu(){
while true
do
        echo -n "*"
        sleep 0.5
done
}

MYUSER="root"
MYPASS="centos"
SOCKET="/var/lib/mysql/mysql.sock"
MYLOGIN="mysql -u${MYUSER} -p${MYPASS} -S${SOCKET} -e"
MYDBBACK="mysqldump -u${MYUSER} -p${MYPASS} -B"
MYTBBACK="mysqldump -u${MYUSER} -p${MYPASS}"
DB_BACK_DIR=/data/back/DBBACK
TB_BACK_DIR=/data/back/TBBACK
BACK=/data/back/OLDBACK
TIME=$(date -d "1 day ago" +"%F")
[ -d ${BACK} ] || mkdir -pv ${BACK} &>/dev/null
[ -d ${DB_BACK_DIR} ] && mv ${DB_BACK_DIR}/* ${BACK} || mkdir -p ${DB_BACK_DIR}
[ -d ${TB_BACK_DIR} ] && mv ${TB_BACK_DIR}/* ${BACK} || mkdir -p ${TB_BACK_DIR}

${MYLOGIN} "show databases;" | egrep -v "^(Database|performance_schema|information_schema|mysql)" > /data/DB.file
echo "start -------------------------------------------------------> `date "+%F %T"`" 

jindu &
for DB in $(cat /data/DB.file);do
	${MYDBBACK} ${DB} | gzip > ${DB_BACK_DIR}/${DB}_$(date +%F).sql.gz 
	for DBTB in $( $MYLOGIN "use ${DB};show tables" | sed "1d")
	do
		${MYTBBACK} ${DB} ${DBTB} | gzip > ${TB_BACK_DIR}/${DBTB}_$(date +%F).sql.gz
	done
done

echo "stop -------------------------------------------------------> `date "+%F %T"`"
echo 

for i in $(ls ${BACK})
do
	if [[ "$i" =~ .*${TIME}.* ]]
	then
		rm -rf ${BACK}/${i}
	fi
done


kill -9 $!
