#!/bin/bash
SINK="@DEFAULT_AUDIO_SINK@"

# Get current volume (0-100)
VOL_RAW=$(wpctl get-volume "$SINK" 2>/dev/null)
VOL=$(echo "$VOL_RAW" | awk '{print $2}')
VOL_INT=$(echo "$VOL" | awk '{printf "%d",$1*100}' 2>/dev/null || echo 0)

# Check if muted
if echo "$VOL_RAW" | grep -q "MUTED"; then
  ICON="audio-volume-muted"
elif [ "$VOL_INT" -eq 0 ]; then
  ICON="audio-volume-muted"
elif [ "$VOL_INT" -lt 30 ]; then
  ICON="audio-volume-low"
elif [ "$VOL_INT" -lt 70 ]; then
  ICON="audio-volume-medium"
else
  ICON="audio-volume-high"
fi

# Show notification
dunstify -a "Volume" -h int:value:"$VOL_INT" -h int:max:100 "Volume level"