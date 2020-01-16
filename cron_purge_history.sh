#!/bin/bash

#every day
#0 1 * * * /bin/bash /usr/lib/zabbix/alertscripts/zabbix2slackBot/cron_purge_history.sh

BASEDIR=$(dirname "$0")

#load config data
if [[ -e "${BASEDIR}/slackbot.config.sh" ]]; then
     source ${BASEDIR}/slackbot.config.sh
else
    exit
fi

#remove logs
echo ${LOG_FOLDER}
find ${LOG_FOLDER} -type f -name '*.log' -mtime +30 | wc -l
find ${LOG_FOLDER} -type f -name '*.log' -mtime +30 -exec rm {} \;
find ${LOG_FOLDER} -type f -name '*.log' -mtime +30 | wc -l

#remove charts
echo ${chart_basedir}
find ${chart_basedir} -type f -name '*.png' -mtime +30 | wc -l
find ${chart_basedir} -type f -name '*.png' -mtime +30 -exec rm {} \;
find ${chart_basedir} -type f -name '*.png' -mtime +30 | wc -l


