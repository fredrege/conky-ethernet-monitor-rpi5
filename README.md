# Network Status Upgrade for Conky on Raspberry Pi

<img width="300" alt="eth-connected" src="https://github.com/user-attachments/assets/dd0ee941-7035-42ed-a0d0-6ec44a72e582" />
<img width="300" alt="eth-disconnected" src="https://github.com/user-attachments/assets/e1e46e7b-89d0-4ce2-9ebf-c06369643915" />

Conky's `${if_up}` monitoring function works well with native Wi-Fi devices (wlan0), but not-so-much with default ethernet devices (eth0 or end0): some state changes don't update the UI.

This repo solves Conky's ethernet monitoring problem with a custom listener. It also adds clearer messaging as to your device's current status.

## Features

- **Event-Driven Monitoring**  
Instead if constant polling, this upgrade uses `nmcli monitor` to detect state changes with 0% idle CPU usage.
- **Modular Design**  
A `Systemd` service handles background logic so Conky stays lean.
- **Clear Status Indication**  
  A bright green message when connected, and a clear red DISCONNECTED message when the device is not able to transfer data.
	
## Requirements
- An updated and upgraded Linux OS  
  Tested on rpi3 and rpi5 running Debian OS - may work on other Linux flavors.
- Conky desktop monitor  
  Installed and running on startup **before** you add this repository. If you're starting from scratch, consider installing [Pi-apps](https://pi-apps.io/install/) first, then install Conky from within the Pi-apps utility.
- An up and running NetworkManager utility  
  Run `nmcli -t` from your terminal to confirm.
- A cursory knowledge of Conky's custom markup syntax. Even if you've never seen it before, but you know HTML or Markdown, you should be able to understand it in a few minutes.

## Installation
1. Clone the repository  
```
cd $HOME
git clone https://github.com/fredrege/conky-ethernet-monitor-rpi5.git
cd conky-ethernet-monitor-rpi5
```
2. Run the installer
```
./install.sh
```
3. Open your Conky configuration file  
Open `.conkyrc` in your favorite editor (it's usually in your user's `$HOME` directory). Use the following to edit via nano in your terminal:  
```
 nano $HOME/.conkyrc
```
4. Replace the networking content  
Within the file's `conky.text` section, comment out the existing ethernet activity markup (or backup `.conkyrc`, in case you want to revert later). Replace the default networking markup with the following:  
```
${color #AAAAAA}Ethernet Status: $alignr ${execp cat /tmp/eth_status.txt}
```
5. Wrap it up  
Save and close `.conkyrc`. If Conky was running, it should restart automatically and load the new monitor.

6. Test your installation  
While watching your Conky desktop utility, plug in and unlug your Pi's ethernet cable repeatedly. The `Ethernet Status` should toggle between verbose "CONNECTED" information and a shorter red "DISCONNECTED" statement, respectively.

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
