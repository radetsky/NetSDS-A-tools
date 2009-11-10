#/bin/sh

MON=$1

if [ -z "$1" ]
then
	        MON=`date -d '30 days ago' +%Y%m%d`
fi
cd /var/spool/asterisk/monitor/
#MON=`date -d '30 days ago' +%Y%m%d`
#find . -name '*'$MON'*.wav' -exec nice -n 19 tar -rvf /var/tmp/$MON.tar '{}' --remove-files \;
find . -atime +30 -delete

