#!/usr/bin/env bash

# Whisper Dictation Script
# Press the shortcut to start recording; press again to stop, transcribe
# with Whisper large-v3-turbo, and type the result into the focused window.

AUDIO="/tmp/dictate.wav"
PIDFILE="/tmp/dictate.pid"
TXT="/tmp/dictate.txt"
MODEL="large-v3-turbo"

if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
    # Stop recording and transcribe
    kill "$(cat "$PIDFILE")" 2>/dev/null
    rm -f "$PIDFILE"
    notify-send "Dictation" "Transcribing..." -t 2000

    if whisper "$AUDIO" --model "$MODEL" --language en --task transcribe \
        --device cuda --output_format txt --output_dir /tmp 2>/dev/null; then
        if [ -s "$TXT" ]; then
            wtype --kde -s 5 < "$TXT"
            notify-send "Dictation" "Transcribed and typed"
        else
            notify-send "Dictation" "No speech detected" -i dialog-error
        fi
    else
        notify-send "Dictation" "Transcription failed" -i dialog-error
    fi
    rm -f "$AUDIO" "$TXT"
else
    # Start recording
    rm -f "$AUDIO" "$TXT" "$PIDFILE"
    ffmpeg -y -hide_banner -loglevel error -f pulse -i default -ac 1 -ar 16000 "$AUDIO" &
    echo $! > "$PIDFILE"
    notify-send "Dictation" "Recording... (press shortcut again to stop)" -t 3000
fi