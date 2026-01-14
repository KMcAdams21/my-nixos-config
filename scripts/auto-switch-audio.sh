#!/usr/bin/env bash

# Names of the sinks
# Use 'wpctl status' and 'wpctl inspect <ID>' to find these names.
HEADSET_SINK="alsa_output.usb-SteelSeries_Arctis_Nova_7-00.analog-stereo"
SPEAKER_SINK="alsa_output.usb-ACTIONS_Pebble_V3-00.analog-stereo"

# Function to check headset state
check_headset() {
    # Check if headsetcontrol is installed
    if ! command -v headsetcontrol &> /dev/null; then
        echo "Error: headsetcontrol is not installed."
        echo "Please install it via NixOS configuration (environment.systemPackages)."
        return 2
    fi

    # headsetcontrol -b returns "Battery: 100%" or similar if on.
    # We capture stderr too because some errors go there.
    OUTPUT=$(headsetcontrol -b 2>&1)
    
    # Check for success output (Battery status)
    if [[ "$OUTPUT" == *"Battery"* ]]; then
        # Headset is ON and reporting battery
        return 0 
    else
        # Headset is OFF, Disconnected, or Erroring
        # Debug: echo "Headset Status Output: $OUTPUT"
        return 1 
    fi
}

echo "Checking headset state..."
check_headset
STATUS=$?

if [ $STATUS -eq 0 ]; then
    echo "Headset detected (ON). Switching default sink to Headphones."
    wpctl set-default "$HEADSET_SINK"
elif [ $STATUS -eq 1 ]; then
    echo "Headset not detected (OFF). Switching default sink to Speakers."
    wpctl set-default "$SPEAKER_SINK"
else
    echo "Skipping switch due to missing dependencies."
fi
