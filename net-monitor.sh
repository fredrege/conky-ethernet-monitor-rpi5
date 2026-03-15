#!/bin/bash

#This script works with other files to write main ethernet device\'s status to a tmp file if and when there is a change in device status.
#Unlike the Conky exec function, we listen for a change and only then, act on it, not poll the state often unnecessarily.
#A handful of files support this objective:
#	1.$HOME/.conkyrc (the Conky configuration file)
#	2.$HOME/bin/net-monitor.sh (this script file)
#	3.$HOME/.config/systemd/user/net-monitor.service (a unit file containing execution instructions)
#	4.a txt file which holds the device\'s current state. It\'s path and file name are declared below.
# 

DEVICE="end0"
STATE_FILE="/tmp/eth_status.txt" #/tmp lives in RAM so we're not beating up our SSD
CNCTD_STRING='${color green}CONNECTED
${voffset 4}${color #505050}IP on end0 $alignr ${color #AAAAAA}${addr end0}
${color #505050}Down $alignr ${color #AAAAAA}${downspeed end0}/sec
${color #505050}Up $alignr ${color #AAAAAA}${upspeed end0}/sec
${color #505050}Downloaded: $alignr ${color #AAAAAA}${totaldown end0}
${color #505050}Uploaded: $alignr ${color #AAAAAA}${totalup end0}' #single quotes tell bash to treat special character\'s literally - do not parse them.

### end of variable declarations

# 1st. Give the desktop a moment to settle after login
sleep 2

# 2nd. INITIAL STATE CHECK (The "Startup Query")
# We grab the current state from the network monitor function
CURRENT_STATE=$(nmcli device status 2>/dev/null | awk -v dev="$DEVICE" '$1 == dev {print $3}')

if [[ "$CURRENT_STATE" == "connected" ]]; then
    echo "$CNCTD_STRING" > "$STATE_FILE"
else
    echo '${color red}DISCONNECTED' > "$STATE_FILE"
fi

# 3rd. NOW START THE MONITOR (The "Event Listener") with a do-while loop
nmcli monitor | while read -r line; do
    if [[ "$line" == *"$DEVICE: connected"* ]]; then
        echo "$CNCTD_STRING" > "$STATE_FILE"

    elif [[ "$line" == *"$DEVICE: unavailable"* ]] || [[ "$line" == *"$DEVICE: disconnected"* ]]; then
        echo '${color red}DISCONNECTED' > "$STATE_FILE"
    fi
done
