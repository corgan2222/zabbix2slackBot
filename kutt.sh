#!/bin/bash

#KUTT_HOST="https://kutt.it"
#KUTT_API_KEY="API_KEY"
#set -x

BASEDIR=$(dirname "$0")

#load config data
if [[ -e "${BASEDIR}/slackbot.config.sh" ]]; then
     source ${BASEDIR}/slackbot.config.sh
else
    exit
fi


	if [[ "$1" == "delete" ]] && [[ -n "$2" ]]; then
		curl -s -H "X-API-KEY: $KUTT_API_KEY" -X DELETE "$KUTT_HOST/api/v2/links/$2" | jq ".link"
	elif [[ -z "$1" ]]; then
		curl -s -H "X-API-KEY: $KUTT_API_KEY" "$KUTT_HOST/api/v2/links" | jq 			
	elif [[ "$1" != "help" ]] && [[ "$1" != "--help" ]]; then
		curl -s -H "X-API-KEY: $KUTT_API_KEY" \
			-H "Content-Type: application/json" \
			--data "{
				\"target\": \"$1\",
				\"password\": \"$2\",
				\"expire_in\": \"$3\",
				\"description\": \"$4\"
			}" \
			"$KUTT_HOST/api/v2/links" | jq -r ".link"
	fi		
	


