#!/usr/bin/env bash

NET=$(nmcli -t -f IN-USE,SSID,RATE,BARS dev wifi)

# Show wofi menu
WIFI_CHOICE=$(echo "$NET" | sed '/^$/d' | wofi --dmenu -s "$HOME/.config/wofi/styles/select_styles.css" -p "Select Wi-Fi SSID")

[ -z "$WIFI_CHOICE" ] && exit 0

# Extract IN-USE, SSID, SECURITY using IFS and read
IFS=':' read -r IN_USE SSID SECURITY <<< "$WIFI_CHOICE"

echo "SSID: $SSID"
echo "SECURITY: $SECURITY"

# Prompt for password if needed
if [[ "$SECURITY" != "--" ]]; then
    PASSWORD=$(echo "ENTER PASSWORD" | wofi --dmenu -c "$HOME/.config/wofi/more_configs/config_password" -s "$HOME/.config/wofi/styles/password_styles.css" -p "Enter Wi-Fi Password" --password)
    nmcli device wifi connect "$SSID" password "$PASSWORD"
else
    nmcli device wifi connect "$SSID"
fi

# Check if the connection was successful
if [[ $? -eq 0 ]]; then
    dunstify  "Wi-Fi Connected" "$SSID"
else
    dunstify -a "Warning" "Wi-Fi Connection Failed" "$SSID"
fi
