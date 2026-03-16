# Network Status Upgrade for Conky on Raspberry Pi

Conky's `${if_up}` monitoring function works well with native Wi-Fi devices (wlan0). But for default ethernet ports (eth0 or end0), `${if_up}` doesn't update on some port state changes.

This repo solves Conky's ethernet monitoring problem with a custom listener. It also adds better visibility to your port's current status.

## Features

- **Event-Driven Monitoring**  
Instead if constant polling, this upgrade uses `nmcli monitor` to detect state changes with 0% idle CPU usage.
- **Modular Design**  
A `Systemd` service handles background logic so Conky stays lean.
	
## Requirements
- An updated and upgraded Linux OS
Tested on rpi3 and rpi5 running Debian OS - may work on other Linux flavors.
- Conky desktop monitor
  	Installed and running on startup **before** you add this repository. If you're starting from scratch, consider installing [Pi-apps](https://pi-apps.io/install/) first, then install Conky from within the Pi-apps utility.
- An up and running NetworkManager utility
  	Run `nmcli -t` from your terminal to confirm.

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
3. Update Conky  
Open `.conkyrc` in your favorite editor (it's usually in the `$HOME` directory)  
	```
	nano $HOME/.conkyrc
	```
	Within the file's `conky.text` section, comment out the existing ethernet activity markup (or backup `.conkyrc`, in case you want to revert later).
	Replace the default markup with the following:
	```
	${color #AAAAAA}Ethernet Status: $alignr ${execp cat /tmp/eth_status.txt}
	```
	
	Save and close `.conkyrc`. If Conky was running, it should restart automatically and load the new monitor. 

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
