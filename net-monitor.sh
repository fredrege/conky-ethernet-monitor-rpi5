#!/bin/bash

#An event listener looking for STATE changes on raspberry pi ethernet ports. On changes, writes to a tmp file read by (and displayed by) a conky desktop monitor.

STATE_FILE="/tmp/eth_status.txt" #/tmp lives in RAM so we're not beating up our SSD
MRKUP_FILE="${HOME}/.config/conky/eth-markup.txt" #the installer script put the custom markup here

#1. Let the desktop settle in after login
    sleep 2

#2. Discover and store the ethernet device's name (etho on older Pis, end0 on rpi5)
    # Get all devices of type 'ethernet' and store them in an array
    # ETH_DEVICES=($(nmcli -t -f DEVICE,TYPE device | awk -F: '$2=="ethernet" {print $1}'))
    ETH_DEVICES=($(nmcli -t -f DEVICE,TYPE device | awk -F: '($2=="ethernet") && ($1=="eth0" || $1=="end0") {print $1}'))
    
    # Check if we found anything at all
    if [ ${#ETH_DEVICES[@]} -eq 0 ]; then
        echo "Error: No ethernet devices detected."
        exit 1
    fi
    
    # Assign the first detected device to DEVICE variable
    DEVICE="${ETH_DEVICES[0]}"
    
    # Now that we know what the primary ethernet device is called, we can write
    #that name into the custom markup. Then save the whole thing into a local string
    CNCTD_STRING=$(eval "$(cat $MRKUP_FILE)")
    echo "string value: $CNCTD_STRING"
    
    # For Raspberry Pis with multiple ports, create dynamic variables
    #not active now. May be used in a later release to support reporting on devices
    #with multiple ethernet ports
    for i in "${!ETH_DEVICES[@]}"; do
        # This creates variables like ETH_DEV_0, ETH_DEV_1, etc.
        eval "ETH_DEV_$i=${ETH_DEVICES[$i]}"
    done
    
    echo "Primary ethernet device detected: $DEVICE"

#3. initial STATE chack (The "Startup Query")
    #grab the current state from nmcli's static device status function
    CURRENT_STATE=$(nmcli device status 2>/dev/null | awk -v dev="$DEVICE" '$1 == dev {print $3}')
    
    if [[ "$CURRENT_STATE" == "connected" ]]; then
        echo "$CNCTD_STRING" > "$STATE_FILE"
    else
        echo '${color red}DISCONNECTED' > "$STATE_FILE" #short enough not to manage in an external file
    fi

#4. Start the device monitor (an "event listener") with a do-while loop. 
    #The service only calls this loop on state changes.
    nmcli monitor | while read -r line; do
        if [[ "$line" == *"$DEVICE: connected"* ]]; then
            echo "$CNCTD_STRING" > "$STATE_FILE"
    
        elif [[ "$line" == *"$DEVICE: unavailable"* ]] || [[ "$line" == *"$DEVICE: disconnected"* ]]; then
            echo '${color red}DISCONNECTED' > "$STATE_FILE"
        fi
done
