# Network Status Upgrade for Conky on Raspberry Pi

<img width="300" alt="eth-connected" src="https://github.com/user-attachments/assets/dd0ee941-7035-42ed-a0d0-6ec44a72e582" />
<img width="300" alt="eth-disconnected" src="https://github.com/user-attachments/assets/e1e46e7b-89d0-4ce2-9ebf-c06369643915" /><p />

  
Conky's `${if_up}` monitoring function works well with native Wi-Fi devices (wlan0), but not-so-much with default ethernet devices (eth0 or end0): some state changes don't update the UI.

This repo seeks to solve Conky's ethernet monitoring problem with a custom listener. It also adds clearer messaging as to your device's current status.

## Requirements
- An updated and upgraded Linux OS.  
  Tested on rpi3 and rpi5 running Debian OS - may work on other Linux flavors.
- Conky desktop monitor.  
> [!IMPORTANT]
> Conky should be installed and running **before** you add this repository. If you're starting from scratch, consider installing [Pi-apps](https://pi-apps.io/install/) first, then install Conky from within the Pi-apps utility.
- An up and running NetworkManager utility.   
  Run `nmcli -t` from your terminal to confirm.
- `awk` and `sed`: text processing and manipulation commands in Linux.  
  Type `awk --version` and `sed --version` in your terminal to confirm.
- A cursory knowledge of Conky's custom markup syntax. Even if you've never seen it before, but you know HTML or Markdown, you should be able to understand it in a few minutes.

## Features

- **Event-Driven Monitoring**  
Instead of constant polling, this upgrade uses `nmcli monitor` to detect state changes with 0% idle CPU usage.
- **Modular Design**  
A `Systemd` service handles background logic so Conky stays lean. As well, we store long-form Conky markup in a separate configuration file (`eth-markup.txt`) for easier styling without editing the core logic script.
- **Clearer Status Indication**  
  A bright green message when connected, and a clear red DISCONNECTED message when the device is not able to transfer data.

## Installation
1. Clone the repository:  
```
cd $HOME
git clone https://github.com/fredrege/conky-network-upgrade.git
cd conky-network-upgrade
```
2. Run the installer:
```
./install.sh
```
3. Open your Conky configuration file:  
Open `.conkyrc` in your favorite editor (it's usually in your user's `$HOME` directory):  
```
 nano $HOME/.conkyrc
```
4. Edit the *Network* content:  
Within the file's `conky.text` section, replace the default networking markup with the following:  
```
${color #AAAAAA}Ethernet Status: $alignr ${execp cat /tmp/eth_status.txt}
```
>[!WARNING]
> Back up your original `.conkyrc` file. At a minimum, comment out the original network activity markup so you can revert this change easily.

5. Wrap it up:  
Save and close `.conkyrc`. If Conky was running, it should restart automatically and load the new monitor.

6. Test your installation:  
While watching your Conky desktop utility, plug in and unplug your Pi's ethernet cable repeatedly. The `Ethernet Status` should toggle between verbose "CONNECTED" information and a shorter red "DISCONNECTED" statement, respectively.

## Control the Service
Start, stop, restart, and get the status of this custom listener from a single parameter:
```
net-monitor-ctrl.sh [start|stop|restart|status]
```
> [!NOTE]
> This script lives in $HOME/bin/, which is in $PATH, thus should be executable from any directory.

## Uninstall

To remove these Conky customizations and stop the associated background processes:

### Automated Uninstall (Recommended)
1. Run the provided uninstall script:
```
cd $HOME/conky-network-upgrade
chmod +x uninstall.sh
./uninstall.sh
```
2. Clean up... remove the repo directory:
```
cd $HOME
rm -rf conky-network-upgrade
```
3. Restore the default *Network* monitoring markup
>[!WARNING]
>Don't skip this step. You don't want Conky looking for a file that isn't there.
Open `.conkyrc`:
```
nano $HOME/.conkyrc
```
Now replace the custom markup with the orignal. It may have looked like this:
>[!IMPORTANT]
> Your version of Conky's *Network* content may have differed. This custom markup is provided as an example.
```
${font Arial:bold:size=10}${color #00AAFF}NETWORK ${color #0000AA}${hr 2}
$font${color #505050}IP on eth0 $alignr ${color #AAAAAA}${addr eth0}

${color #505050}Down $alignr ${color #AAAAAA}${downspeed eth0}/s
${color #505050}Up $alignr ${color #AAAAAA}${upspeed eth0}/s

${color #505050}Downloaded: $alignr  ${color #AAAAAA}${totaldown eth0}
${color #505050}Uploaded: $alignr  ${color #AAAAAA}${totalup eth0}
```
Save your changes and close the editor.

4. restart Conky:
```
conky -d
```
You're done. Conky should be up and running with the default *Network* experience displayed.

### Manual Uninstall
>[!NOTE]
>If you used the automated uninstall directions above, skip this section.

Circumspect developers may prefer to see under the hood (or bonnet &#x1F1EC;&#x1F1E7;) and remove things by hand:
1. Kill Conky:
```
    killall conky
```
2. Stop and disable the service:
```
    systemctl --user stop net-monitor.service
    systemctl --user disable net-monitor.service
```
3. Remove the service file:
```
    rm $HOME/.config/systemd/user/net-monitor.service
    systemctl --user daemon-reload
```
4. Remove the scripts and temporary files:
```
    rm $HOME/bin/net-monitor.sh
    rm $HOME/bin/net-monitor-ctrl.sh
    rm -rf $HOME/bin/.config/conky
    rm /tmp/eth_status.txt
```
Note that removing the directory `$HOME/bin/.config/conky` will also delete the custom markup file in the associated path: `$HOME/bin/.config/conky/eth-markup.txt`.

5. Remove the installation directory:
```
    cd $HOME
    rm -rf conky-network-upgrade
```
6. Restore the default *Network* monitoring markup
>[!WARNING]
>Don't skip this step. You don't want Conky looking for a file that isn't there.
Open `.conkyrc`:
```
nano $HOME/.conkyrc
```
Now replace the custom markup with the orignal. It may have looked like this:
>[!IMPORTANT]
> Your version of Conky's *Network* content may have differed. This custom markup is provided as an example.
```
${font Arial:bold:size=10}${color #00AAFF}NETWORK ${color #0000AA}${hr 2}
$font${color #505050}IP on eth0 $alignr ${color #AAAAAA}${addr eth0}

${color #505050}Down $alignr ${color #AAAAAA}${downspeed eth0}/s
${color #505050}Up $alignr ${color #AAAAAA}${upspeed eth0}/s

${color #505050}Downloaded: $alignr  ${color #AAAAAA}${totaldown eth0}
${color #505050}Uploaded: $alignr  ${color #AAAAAA}${totalup eth0}
```
Save your changes and close the editor.

7. Restart Conky:
```
conky -d
```
 
## Troubleshooting

- Your conky window resizes into a small window during OS startup.
Conky is probably loading before the desktop layout finished loading. Try increasing the sleep timer before the application loads:
```
nano $HOME/.config/autostart/conky.desktop
```
change `sleep 5` to `sleep 10`. Save, close, and reboot.
- Conky positioning doesn't seem to follow adjusted values.
Within .conkyrc, the minimum width is likely set too high.
```
nano $HOME/.conkyrc
```
Change `minimum_width = 250` to `minimum_width = 160`. Save your change - conky shoudld reload and reposition itself appropriately.
Make sure the utility doesn't "land" on your Taskbar (it can cause UI problems later). gap_x=50 and gap_y=120 work if alignment='top_right'
