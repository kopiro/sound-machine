#!/bin/bash
set -e

BLACKHOLE=false
SAVE=false
PLAY=false
NAME=""

for arg in "$@"; do
  case "$arg" in
    --blackhole) BLACKHOLE=true ;;
    --save) SAVE=true ;;
    --play) PLAY=true ;;
    *) NAME="$arg" ;;
  esac
done

if [ -z "$NAME" ]; then
  echo "Usage: ./record-sound.sh <name> [--blackhole]"
  exit 1
fi

DIR="$(dirname "$0")/sounds"
OUT="${DIR}/${NAME}.mp3"
TMP="${DIR}/${NAME}_raw.wav"

while true; do
  if $BLACKHOLE; then
    echo "Recording from BlackHole 2ch... Press Ctrl+C to stop."
    AUDIODEV="BlackHole 2ch" rec "$TMP" 2>/dev/null || true
  else
    echo "Recording... Press Ctrl+C to stop."
    rec "$TMP" 2>/dev/null || true
  fi

  echo "Trimming silence and converting to mp3..."
  sox "$TMP" "$OUT" silence 1 0.1 -50d reverse silence 1 0.1 -50d reverse
  rm "$TMP"
  echo "Saved: $OUT"

  if $PLAY; then
    play "$OUT" 2>/dev/null
    read -rp "Keep this? (y/n) " ANSWER
    [ "$ANSWER" = "y" ] && break
    echo "Retrying..."
  else
    break
  fi
done

if $SAVE; then
  JSON="$(dirname "$0")/sounds.json"

  read -rp "Display name: " DISPLAY_NAME
  read -rp "Emoji: " ICON

  # Add entry to sounds.json
  TMP_JSON="${JSON}.tmp"
  jq --arg name "$DISPLAY_NAME" \
     --arg sound "sounds/${NAME}.mp3" \
     --arg icon "$ICON" \
     '. += [{"name": $name, "sound": $sound, "icon": $icon}]' \
     "$JSON" > "$TMP_JSON"
  mv "$TMP_JSON" "$JSON"

  echo "Added \"$DISPLAY_NAME\" to sounds.json"
fi
