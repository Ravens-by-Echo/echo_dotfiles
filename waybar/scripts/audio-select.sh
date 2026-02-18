#!/usr/bin/env bash

# -------- AUDIO OUTPUTS (SINKS) --------
SINKS=$(wpctl status \
  | sed -n '/├─ Sinks:/,/├─ Sources:/p' \
  | grep -E '^[ │]*[\* ]+[0-9]+\.' \
  | sed -E 's/^[ │]*\*\s*([0-9]+)\. (.*) \[vol.*/CURRENT|AUDIO|\1|\2/;
            s/^[ │]*\s*([0-9]+)\. (.*) \[vol.*/NORMAL|AUDIO|\1|\2/')

# -------- MICROPHONES (SOURCES) --------
MICS=$(wpctl status \
  | sed -n '/├─ Sources:/,/├─ Filters:/p' \
  | grep -E '^[ │]*[\* ]+[0-9]+\.' \
  | sed -E 's/^[ │]*\*\s*([0-9]+)\. (.*)/CURRENT|MIC|\1|\2/;
            s/^[ │]*\s*([0-9]+)\. (.*)/NORMAL|MIC|\1|\2/')

# -------- COMBINE & SORT (current first) --------
CHOICE=$(printf "%s\n%s\n" "$SINKS" "$MICS" \
  | sort -t'|' -k1,1 \
  | awk -F'|' '{
      if ($1=="CURRENT")
        print "★ " $2 ": " $4 " (" $3 ")"
      else
        print "  " $2 ": " $4 " (" $3 ")"
    }' \
  | wofi --dmenu -s "$HOME/.config/wofi/styles/select_styles.css" -p "Select audio device")

[ -z "$CHOICE" ] && exit 0

# -------- EXTRACT TYPE & ID --------
TYPE=$(echo "$CHOICE" | awk -F': ' '{print $1}' | sed 's/^★ //;s/^  //')
ID=$(echo "$CHOICE" | sed -E 's/.*\(([0-9]+)\)/\1/')

# -------- APPLY SELECTION --------
wpctl set-default "$ID"

# -------- NOTIFICATION --------
if [ "$TYPE" = "AUDIO" ]; then
  dunstify "󰕾 Audio Output" "Default sink set to ${CHOICE#*: }"
else
  dunstify "󰍬 Microphone" "Default source set to ${CHOICE#*: }"
fi
