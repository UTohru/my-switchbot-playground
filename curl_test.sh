#!/usr/bin/env bash

# BOT_TOKEN=""
# curl "https://api.switch-bot.com/v1.0/devices" -H "Authorization: ${BOT_TOKEN}" | jq .

endpoint="******/****/devices/******?action=add&state=true"
API_KEY=""

curl -X GET $endpoint \
     -H "Content-Type:application/json" \
     -H "x-api-key:${API_KEY}"

