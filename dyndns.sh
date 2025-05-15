#!/bin/bash

#------------------------------------------------------------------------------
# Cloudflare DNS Update Script
#
# License: GNU GPL v3.0
#------------------------------------------------------------------------------

# Exit with code 1 if no configuration file is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <config-file>"
    echo "Error: No configuration file provided."
    exit 1
fi

CONFIG_FILE=$1

CLOUDFLARE_URL="https://api.cloudflare.com/client/v4/zones/"

# Read configuration values from the config file
API_TOKEN=$(sed -n '1p' $CONFIG_FILE)
ZONE_ID=$(sed -n '2p' $CONFIG_FILE)
RECORD_NAME=$(sed -n '3p' $CONFIG_FILE)

function fetch_record_id {
    echo $(curl -sS -X GET "${CLOUDFLARE_URL}${ZONE_ID}/dns_records" \
    -H "Authorization: Bearer $API_TOKEN" \
    -H "Content-Type: application/json" \
    | jq -r '.result[] | select(.comment == "dyndns") | .id')
}

RECORD_ID=$(fetch_record_id)

# current public ip address
IP=$(curl -s https://api64.ipify.org)

# ip address as configured in dns configuration
DNS_IP=$(dig +short "$RECORD_NAME")

URL="${CLOUDFLARE_URL}${ZONE_ID}/dns_records/$RECORD_ID"

function update_ip {
    echo "Updating DNS record for $RECORD_NAME"
    RESPONSE=$(curl -s -X PUT "$URL" \
    -H "Authorization: Bearer $API_TOKEN" \
    -H "Content-Type: application/json" \
    --data '{
      "type": "A",
      "name": "'"$RECORD_NAME"'",
      "content": "'"$IP"'",
      "comment": "dyndns",
      "ttl": 60,
      "proxied": false
    }')
}

# Compare current public IP with DNS record IP
if [ "$IP" != "$DNS_IP" ]; then
  echo "The IP Adress has changed: $DNS_IP → $IP"
  update_ip
else
  echo "The IP Adress is identical. No update needed."
fi
