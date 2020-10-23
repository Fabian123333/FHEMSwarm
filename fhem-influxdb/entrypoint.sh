#!/bin/bash
FHEM_SCRIPT="/opt/fhem/fhem.pl"
FHEM_PATH="/opt/fhem"
FHEM_CONFIG_PATH="/opt/fhem/conf/"

cd $FHEM_PATH

while [ ! -d $FHEM_CONFIG_PATH ]; do
	echo "wait for fs initialisation"
	sleep 2
done

## inital setup
ls "$FHEM_SCRIPT" 2>/dev/null || {
	echo "perform initial setup"
	tar xzf /fhem.tar.gz -C /tmp
	rsync -a --ignore-existing /tmp/fhem-*/ /opt/fhem/
	rm -r /tmp/fhem-6.0
	ls "${FHEM_CONFIG_PATH}fhem.cfg" || {
		echo "create new config"
		mv "/opt/fhem/fhem.cfg" "${FHEM_CONFIG_PATH}"
		echo "define logdb DbLog ${FHEM_CONFIG_PATH}dbLog.conf .*:.*" >> ${FHEM_CONFIG_PATH}fhem.cfg
	}
}

#if ! mysql -h db -u fhem -pfhem -e "desc fhem.history"; then
#	echo "create tables"
#	while read line; do
#		echo $line | mysql -h db -u fhem -pfhem
#	done < /opt/fhem/contrib/dblog/db_create_mysql.sql
#fi;

sed -i "s/^attr global backup_before_update.*$//g" ${FHEM_CONFIG_PATH}fhem.cfg
sed -i "s/^attr global backupdir .*$//g" ${FHEM_CONFIG_PATH}fhem.cfg

if [ ! -z "$FHEM_BACKUP" ]; then
	echo "enable backup"
        echo "attr global backup_before_update 1" >> ${FHEM_CONFIG_PATH}fhem.cfg
        echo "attr global backupdir /backup" >> ${FHEM_CONFIG_PATH}fhem.cfg
fi

if [ ! -z "$FHEM_AUTOSAVE" ]; then
	echo "enable autosave"
	sed -i "s/^attr global autosave .*$//g" ${FHEM_CONFIG_PATH}fhem.cfg
        echo "attr global autosave $FHEM_AUTOSAVE" >> ${FHEM_CONFIG_PATH}fhem.cfg
fi

if [ ! -z "$ENABLE_TELNET" ]; then
	echo "enable telnet"
	cat ${FHEM_CONFIG_PATH}fhem.cfg | grep "telnetPort telnet" || echo "define telnetPort telnet 23 global" >> ${FHEM_CONFIG_PATH}fhem.cfg
fi

echo '%dbconfig= ( connection => "influxdb:database=fhem;host=db;port=8806", user => "fhem", password => "fhem");' > ${FHEM_CONFIG_PATH}dbLog.conf

        if [ ! -z "$FHEM_BACKUP" ]; then
                echo "attr global backup_before_update 1" >> ${FHEM_CONFIG_PATH}fhem.cfg
                echo "attr global backupdir /backup" >> ${FHEM_CONFIG_PATH}fhem.cfg
        else
                sed -i "s/^attr global backup_before_update.*$//g" ${FHEM_CONFIG_PATH}fhem.cfg
                sed -i "s/^attr global backupdir .*$//g" ${FHEM_CONFIG_PATH}fhem.cfg
        fi

echo "start fhem"
perl "${FHEM_SCRIPT}" "${FHEM_CONFIG_PATH}fhem.cfg"

while true; do
	sleep 100;
done
