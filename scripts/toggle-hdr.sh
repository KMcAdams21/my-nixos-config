#!/usr/bin/env bash

# HDR Toggle Script for Innocn Monitor (DP-2)
# Toggles HDR and Wide Color Gamut on/off

OUTPUT="DP-2"

# Get current HDR state, stripping ANSI color codes
current_state=$(kscreen-doctor -o 2>/dev/null | sed 's/\x1b\[[0-9;]*m//g' | grep -A 20 "$OUTPUT" | grep "HDR:" | head -1 | awk '{print $2}')

if [ "$current_state" = "enabled" ]; then
    # Disable HDR and WCG
    kscreen-doctor "output.$OUTPUT.hdr.disable" "output.$OUTPUT.wcg.disable"
    notify-send "HDR Disabled" "HDR and Wide Color Gamut disabled on $OUTPUT" -i video-display
else
    # Enable HDR and WCG
    kscreen-doctor "output.$OUTPUT.hdr.enable" "output.$OUTPUT.wcg.enable"
    notify-send "HDR Enabled" "HDR and Wide Color Gamut enabled on $OUTPUT" -i video-display
fi
