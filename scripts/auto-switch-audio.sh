#!/usr/bin/env bash

# Names of the sinks
HEADSET_NAME="alsa_output.usb-SteelSeries_Arctis_Nova_7-00.analog-stereo"
SPEAKER_NAME="alsa_output.usb-ACTIONS_Pebble_V3-00.analog-stereo"

# Function to get ID from Name
get_id() {
    NODE_NAME="$1"
    # Use wpctl status to find the ID associated with the node name
    # We parse the output of wpctl status or inspect. 
    # A more robust way is using grep on wpctl status output because inspect requires ID.
    # We can try to use pw-dump if available, but wpctl is standard.
    # Let's try a simple ID lookup by parsing 'wpctl status' output isn't easy cleanly.
    # Alternative: iterate reasonable IDs? No.
    # Better: Use the fact that errors often hint at issues, but here we explicitly need an ID.
    # Let's try to map names to IDs roughly or ask user to provide IDs if names fail.
    
    # Actually, wpctl set-default SHOULD support names. If it fails, it might be an old version.
    # Let's try to find the ID.
    ID=$(wpctl status | grep -B 1 "$NODE_NAME" | grep "Sink" | awk '{print $2}' | sed 's/\.//')
    
    # If the above simple grep fails (format varies), let's try a broader search
    if [ -z "$ID" ]; then
        # Check if we can find it in the list
        ID=$(wpctl status | grep "$NODE_NAME" -B 10 | grep -E "^ │\s+[0-9]+" | head -n 1 | awk '{print $2}' | sed 's/\.//')
    fi
     # Fallback: Just return the name if ID not found, maybe it will work next time?
    if [ -z "$ID" ]; then
        echo ""
    else
        echo "$ID"
    fi
}

# Function to get ID from Description
get_id_by_desc() {
     # Find the line with the description
     # Iterate through fields to find the one ending in '.', which is the ID
     wpctl status | grep -F "$1" | awk '{ for(i=1;i<=NF;i++) if($i ~ /^[0-9]+\.$/) { gsub(/\./, "", $i); print $i; exit } }'
}

HEADSET_DESC="Arctis Nova 7 Analog Stereo"
SPEAKER_DESC="Pebble V3 Analog Stereo"

# Function to check headset state
check_headset() {
    if ! command -v headsetcontrol &> /dev/null; then
        echo "Error: headsetcontrol is not installed."
        return 2
    fi

    OUTPUT=$(headsetcontrol -b 2>&1)
    # Debug: echo "Debug: headsetcontrol output: $OUTPUT"
    
    # Check for specific "AVAILABLE" status. 
    # When off, it says "Status: BATTERY_UNAVAILABLE"
    # When on, it says "Status: BATTERY_AVAILABLE"
    if echo "$OUTPUT" | grep -q "BATTERY_AVAILABLE"; then
        return 0 
    else
        return 1 
    fi
}

echo "Checking headset state..."
check_headset
STATUS=$?

if [ $STATUS -eq 0 ]; then
    echo "Headset detected (ON)."
    TARGET_ID=$(get_id_by_desc "$HEADSET_DESC")
    if [ -n "$TARGET_ID" ]; then
        echo "Switching to Headset ID: $TARGET_ID"
        wpctl set-default "$TARGET_ID"
    else
        echo "Error: Could not find Headset ID for '$HEADSET_DESC'"
    fi
elif [ $STATUS -eq 1 ]; then
    echo "Headset not detected (OFF)."
    TARGET_ID=$(get_id_by_desc "$SPEAKER_DESC")
    if [ -n "$TARGET_ID" ]; then
        echo "Switching to Speaker ID: $TARGET_ID"
        wpctl set-default "$TARGET_ID"
    else
        echo "Error: Could not find Speaker ID for '$SPEAKER_DESC'"
    fi
else
    echo "Skipping switch due to missing dependencies."
fi
