
# config

#slack infos
slack_url='https://hooks.slack.com/services/xxxxxxxxxxxxx/xxxxxxxxx/xxxxxxxxxxxxxx'
slack_username='Zabbix'

#zabbix login
zabbix_baseurl="https://zabbix"
zabbix_username="user"
zabbix_password="password"

title="$2"
#params="$3"
emoji=':ghost:'
timeout="12"

#bin config
cmd_curl="/usr/bin/curl"
cmd_wget="/usr/bin/wget"

#kutt api v2
KUTT_HOST="https://kutt.it"
KUTT_API_KEY="apikey"
CMD_URL_KUTT="/usr/lib/zabbix/alertscripts/zabbix2slackBot/kutt.sh"


#logfolder
LOG_FOLDER="/var/log/debug"

#grafana link
GRAFANA_LINK="https://website/grafana"

# chart settings
chart_period=3600
chart_width=1280
chart_height=390

#folder to save the charts
chart_baseurl="${zabbix_baseurl}"
chart_completeurl="${zabbix_baseurl}/assets/slack_charts"
chart_basedir="/usr/share/zabbix/assets/slack_charts"

#zabbix login cookie path
chart_cookie="/tmp/zcookies.txt"

#default icons
type_icon="https://website/assets/img/128/z3_128.png"
tag_icon="https://website/assets/img/128/z3_128.png"
icon_basedir="/usr/share/zabbix/assets/img/"
icon_baseurl="https://website/assets/img/128"

type_icon_default="${icon_baseurl}/z3_128.png"
tag_icon_default="${icon_baseurl}/z3_128.png"
status_icon_default="${icon_baseurl}/info.png"