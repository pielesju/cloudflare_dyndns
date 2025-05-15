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

# Read configuration values from the config file
API_TOKEN=$(sed -n '1p' $CONFIG_FILE)
ZONE_ID=$(sed -n '2p' $CONFIG_FILE)
RECORD_NAME=$(sed -n '3p' $CONFIG_FILE)
RECORD_ID=$(sed -n '4p' $CONFIG_FILE)

# current public ip address
IP=$(curl -s https://api64.ipify.org)

# ip address as configured in dns configuration
DNS_IP=$(dig +short "$RECORD_NAME")

URL="https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$RECORD_ID"

function update_ip {
    echo "Updating DNS record for $RECORD_NAME"
    RESPONSE=$(curl -s -X PUT "$URL" \
    -H "Authorization: Bearer $API_TOKEN" \
    -H "Content-Type: application/json" \
    --data '{
      "type": "A",
      "name": "'"$RECORD_NAME"'",
      "content": "'"$IP"'",
      "ttl": 300,
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
