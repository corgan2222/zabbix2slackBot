#!/bin/bash 

BASEDIR=$(dirname "$0")

#load config data
if [[ -e "${BASEDIR}/slackbot.config.sh" ]]; then
     source ${BASEDIR}/slackbot.config.sh
else  
    exit
fi  

dattime=$(date +%Y-%m-%d-%H-%M-%S)

#if come from zabbix
 if [ "${1}" != "" ]; then
    destdir=${LOG_FOLDER}/slack_debug_message_"${dattime}"_.log
    printf "%s" "$3" > "$destdir"
    channel="$1"
    message="$3"    
 else #if script runs without any parameter, try to load saved debug data
    channel="debug" #channel to post in
    message=$(<${LOG_FOLDER}/slack_debug_message_2019-09-20-10-06-10_.log)
 fi


#zabbix data
declare -A ur
while IFS= read -r line ; 
    do 
        a=$(echo $line | cut -d'|' -f1)        
        bbb=$(echo $line | cut -d'|' -f2)

        bb=${bbb//$'\r'/}        
        b=$(echo "$bb" | recode ascii..html)

        ur[$a]=$b
done <<< "${message}"

#colors
function get_color() 
{
    status=$(echo "$1" | tr -d " ")
    severity=$(echo "$2" | tr -d " ")
    ret=$(echo "$3" | tr -d " ")

    if [[ `echo "${status}" | grep 'OK'` ]]; then
        case "${severity}" in
          'Information') 
          color="#439FE0"
          Trigger_icon="info.png" 
          ;;
          *) 
          color="good"
          Trigger_icon="ok.png" 
          ;;
        esac
    elif [[ `echo "${status}" | grep 'PROBLEM'` ]]; then
        case "${severity}" in
          'Information') 
          color="#439FE0"
          Trigger_icon="info_red.png" 
          ;;
          'Warning') 
          color="warning" 
          Trigger_icon="warning.png"
          ;;
          'Disaster') 
          color="warning" 
          Trigger_icon="disaster.png"
          ;;
          *) 
          color="danger" 
          Trigger_icon="danger.png"
          ;;
        esac
    else
        color="#808080"
        Trigger_icon="info.png"
    fi
    
    if [[ `echo "${ret}" | grep 'ICON'` ]]; then
        echo "${Trigger_icon}"
    else 
        echo "${color}"
    fi
}

color=$(get_color "${ur[TRIGGER_STATUS]}" "${ur[TRIGGER_SEVERITY]}" "COLOR" )
Trigger_icon=$(get_color "${ur[TRIGGER_STATUS]}" "${ur[TRIGGER_SEVERITY]}" "ICON" )

#url
StatusIcon_l=${icon_baseurl}/${Trigger_icon}
type_icon_l="${icon_baseurl}/${ur[TYPE]}.png"
tag_icon_l="${icon_baseurl}/${ur[TAG]}.png"

#local folder
StatusIcon_c="${icon_basedir}/${Trigger_icon}" 
type_icon_c="${icon_basedir}/${ur[TYPE]}.png" 
tag_icon_c="${icon_basedir}/${ur[TAG]}.png" 

#type icon
if [[ -e "${type_icon_c}" ]]; then
     type_icon_display="${type_icon_l}"
else  
    type_icon_display="${type_icon_default}"
fi    

#tag icon
if [[ -e "${tag_icon_c}" ]]; then
     tag_icon_display="${tag_icon_l}" 
else 
    tag_icon_display="${tag_icon_default}"
fi    

#status icon
if [[ -e "${StatusIcon_c}" ]]; then 
    status_icon_display="${StatusIcon_l}" 
else
    status_icon_display="${status_icon_default}"
fi    

# get charts
if [ "${ur[ITEM_ID]}" != "" ]; then
    #timestamp=$(date +"%Y-%m-%dT%T.%3N%z")
    timestamp=$(date +%s)    
    ${cmd_wget} --save-cookies="${chart_cookie}_${timestamp}" --keep-session-cookies --post-data "name=${zabbix_username}&password=${zabbix_password}&enter=Sign+in" -O /dev/null -q "${zabbix_baseurl}/index.php?login=1"
    ${cmd_wget} --load-cookies="${chart_cookie}_${timestamp}"  -O "${chart_basedir}/graph-${ur[ITEM_ID]}-${timestamp}.png" -q "${zabbix_baseurl}/chart.php?&itemids=${ur[ITEM_ID]}&width=${chart_width}&period=${chart_period}"
    chart_url="${chart_completeurl}/graph-${ur[ITEM_ID]}-${timestamp}.png"

    rm -f ${chart_cookie}_${timestamp}

    # if triger url is empty then we link to the graph with the item_id
    if [ "${ur[TRIGGER_URL]}" == "" ]; then
        trigger_url=$(${CMD_URL_KUTT} "${zabbix_baseurl}/history.php?action=showgraph&itemids[]=${item_id}")    
    fi

    GRAPH_LINK=$(${CMD_URL_KUTT} "${zabbix_baseurl}/history.php?action=showgraph&itemids[]=${ur[ITEM_ID]}&from=now-1h&to=now")  
    AKK_LINK=$(${CMD_URL_KUTT} "${zabbix_baseurl}/zabbix.php?action=acknowledge.edit&eventids[0]=${ur[EVENT_ID]}")  
fi


if [ "${ur[URL_A]}" != "" ]; then 
    URL_A=$(${CMD_URL_KUTT} "${ur[URL_A]}")      
else
    URL_A="${GRAFANA_LINK}"
fi

if [ "${ur[URL_B]}" != "" ]; then 
    URL_B=$(${CMD_URL_KUTT} "${ur[URL_B]}")  
else
    URL_B="${zabbix_baseurl}"    
fi

#ack link
if [ "${ur[EVENT_ID]}" != "" ]; then     
    ACL_LINK=$(${CMD_URL_KUTT} "${zabbix_baseurl}/zabbix.php?action=acknowledge.edit&eventids[0]=${ur[EVENT_ID]}")    
else
    ACL_LINK="< ${zabbix_baseurl}/zabbix.php?action=problem.view&ddreset=1 | ZP>"
fi

#edit item
if [ "${ur[ITEM_ID]}" != "" ]; then 
    ITEM_LINK=$(${CMD_URL_KUTT} "${zabbix_baseurl}/items.php?form=update&itemid=${ur[ITEM_ID]}")  
else
    ITEM_LINK="${zabbix_baseurl}"    
fi

#edit trigger
if [ "${ur[TRIGGER_ID]}" != "" ]; then 
    TRIGGER_LINK=$(${CMD_URL_KUTT} "${zabbix_baseurl}/triggers.php?form=update&triggerid=${ur[TRIGGER_ID]}")  
else
    TRIGGER_LINK="${zabbix_baseurl}"    
fi

#update and recovery
if [ "${ur[RECOVERY_STATUS]}" == "RESOLVED" ] && [ "${ur[ITEM_ID]}" != "" ]; then
    StatusIcon="${icon_baseurl}/resolved.png"    
    PROBLEM_STARTET="${ur[RECOVERY_TIME]}"
    fixed="RESOLVED "
fi

# set payload
payload="payload={
  \"channel\": \"#officeknaak\",
  \"username\": \"${slack_username}\",
  \"unfurl_links\": \"false\",
  \"icon_url\": \"${type_icon_display}\",   
  \"text\": \"${ur[STATUS]} ${ur[TRIGGER_NAME]}\", 

    \"attachments\": [ 
                        {
                            \"mrkdwn_in\":[\"fields\"],
                            \"title\": \"${ur[HOST]}\",
                            \"title_link\": \"${URL_A}\",
                            \"color\": \"${color}\",
                            \"fields\": [
                                    {
                                        \"title\": \"*${ur[STATUS]} ${ur[TRIGGER_NAME]}*\",
                                        \"value\": \"_${ur[VALUE]}_\",
                                        \"short\": false
                                    } 
                                    ],                                                      
                            \"thumb_url\": \"${type_icon_display}\",
                            \"footer\": \"Startet: ${ur[PROBLEM_STARTET]}\",
                            \"footer_icon\": \"${type_icon_display}\"                               
                        },                                  
                        {                            
                            \"title\": \"${ur[ITEM_KEY]}\",                            
                            \"title_link\": \"${TRIGGER_LINK}\",
                            \"color\": \"${color}\",                            
                            \"fields\": [
                                    {
                                        \"title\": \"*Last Min 90:*\",
                                        \"value\": \"_${ur[LAST_MIN]}_\",
                                        \"short\": true
                                    },
                                    {
                                        \"title\": \"*Last Max 90:*\",
                                        \"value\": \"${ur[LAST_MAX]}\",
                                        \"short\": true
                                    }  
                                    ],                           
                            \"actions\": [
                                           {
                                            \"type\": \"button\",
                                            \"text\": \"Zabbix Ack\",
                                            \"url\": \"${AKK_LINK}\",
                                             \"style\": \"danger\"
                                            },
                                            {
                                            \"type\": \"button\",
                                            \"text\": \"Grafana\",
                                            \"url\": \"${URL_A}\"                                             
                                            },
                                            {
                                            \"type\": \"button\",
                                            \"text\": \"Manage\",
                                            \"url\": \"${URL_B}\"
                                            }, 
                                            {
                                            \"type\": \"button\",
                                            \"text\": \"Item️\",                                            
                                            \"url\": \"${ITEM_LINK}\"
                                            }, 
                                            {
                                            \"type\": \"button\",
                                            \"text\": \"Trigger\",
                                            \"url\": \"${TRIGGER_LINK}\"
                                            } 
                                        ],
                            \"thumb_url\": \"${status_icon_display}\",
                            \"footer\": \"${ur[SITE_A]} | ${ur[SITE_B]}\",
                            \"footer_icon\": \"${tag_icon_display}\"                               
                        },          
                        {
                            \"title\": \"Zabbix Graph History\",
                            \"title_link\": \"${GRAPH_LINK}\",
                            \"color\": \"${color}\",
                                
                            \"image_url\": \"${chart_url}\",
                            \"footer\": \"#${ur[TAG]} #${ur[TYPE]} #${ur[TRIGGER_SEVERITY]} \",
                            \"footer_icon\": \"${status_icon_display}\"  	                          
                         }  
                    ]   
}"

#send
RESPONSE=$(${cmd_curl} -sm ${timeout} --data-urlencode "${payload}" "${slack_url}")  

# Fallback Basic Infos
if [[ "$RESPONSE" != 'ok' ]]; then

    ERROR_LOG=${LOG_FOLDER}/slack_debug_message_"${dattime}"_ERROR_LOG.log
    printf "%s" "%s" "$RESPONSE" "$payload" > "$ERROR_LOG"    

    to=#officeknaak
    subject="${ur[TRIGGER_NAME]}"
    message="${ur[VALUE]}"."${destdir}"."${RESPONSE}"   
    username="${slack_username}" 

    recoversub='^RECOVER(Y|ED)?$|^OK$|^Resolved.*'
    problemsub='^PROBLEM.*|^Problem.*'

    # Build JSON payload which will be HTTP POST'ed to the Slack.com web-hook URL
    payload="payload={\"channel\": \"${to//\"/\\\"}\",  \
    \"username\": \"${username//\"/\\\"}\", \
    \"attachments\": [{\"fallback\": \"${subject//\"/\\\"}\", \"title\": \"${subject//\"/\\\"}\", \"text\": \"${message//\"/\\\"}\", \"color\": \"${color}\"}], \
    \"icon_emoji\": \"${emoji}\"}"

    # Execute the HTTP POST request of the payload to Slack via curl, storing stdout (the response body)
    return=$(curl $proxy -sm 5 --data-urlencode "${payload}" $slack_url -A 'zabbix-slack-alertscript / https://github.com/ericoc/zabbix-slack-alertscript')
    if [[ "$return" != 'ok' ]]; then
        >&2 echo " \n $return"
        exit 1
    fi
else
    >&2 echo " \n $RESPONSE"
    exit 0
fi
