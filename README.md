# Network Status Monitor Upgrade for Conky on Raspberry Pi

On a Rasberry Pi 5, Conky's `${if_up}` function works well with the native wi-fi device (wlan0). But for the Pi's default ethernet port (end0), `${if_up}` doesn't update on some port state changes.

This repo solves the ethernet monitoring problem with a custom listener.

## Features

- **Event-Driven Networking**  
Uses `nmcli monitor` command to detect a state change with 0% idle CPU usage.
- **Modular Design**  
A `Systemd` service handleS background logic so Conky stays lean.
	
## Requirements
- An updated and upgraded Linux OS (tested on rpi3 and rpi5 running Debian OS - may work on other Linux flavors)
- Conky desktop monitor (installed and running on startup before you install this repository.
If you're starting from scratch, consider installing [Pi-apps](https://pi-apps.io/install/) first, then install Conky from within the Pi-apps utility.
- Run `nmcli -v` from your terminal. If it returns a result, your system should have access to the utility.

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
