#!/bin/bash
FHEM_SCRIPT="/opt/fhem/fhem.pl"
FHEM_PATH="/opt/fhem"
FHEM_CONFIG_PATH="/opt/fhem/conf/"

cd $FHEM_PATH

## inital setup
if [ ! -f "$FHEM_SCRIPT" ]; then
	echo "perform initial setup"
	tar xzf /fhem.tar.gz -C /tmp
	mv /tmp/fhem-*/* /opt/fhem
	rm -r /tmp/fhem-6.0
	mkdir ${FHEM_CONFIG_PATH}
	mv "/opt/fhem/fhem.cfg" "${FHEM_CONFIG_PATH}"
	echo "define dbLog DbLog ${FHEM_CONFIG_PATH}dbLog.conf .*:.*" >> ${FHEM_CONFIG_PATH}fhem.cfg
fi

if ! mysql -h db -u fhem -pfhem -e "desc fhem.history"; then
	echo "create tables"
	while read line; do
		echo $line | mysql -h db -u fhem -pfhem
	done < /opt/fhem/contrib/dblog/db_create_mysql.sql
fi;

echo '%dbconfig= ( connection => "mysql:database=fhem;host=db;port=3306", user => "fhem", password => "fhem");' > ${FHEM_CONFIG_PATH}dbLog.conf

echo "start fhem"
perl /opt/fhem/fhem.pl "${FHEM_CONFIG_PATH}fhem.cfg"

while true; do
	sleep 100;
done
