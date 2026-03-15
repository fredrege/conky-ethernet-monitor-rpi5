# Ethernet Status Monitor for Conky on rpi5 (Debian Linux)

On a Rasberry Pi 5, Conky's `${if_up}` function works well with the native wi-fi device (wlan0). But for the Pi's default ethernet port (end0), `${if_up}` doesn't update on some port state changes.

This repo solves the ethernet monitoring problem with a custom listener.

## Features

- **Event-Driven Networking**  
Uses `nmcli device status` to detect a state change with 0% idle CPU usage.
- **Modular Design**  
A `Systemd` service handleS background logic so Conky stays lean.
	
## Requirements
- An updated and upgraded Linux OS (tested on Debian but may work on others)
- A running variant of Navaspirits's [Conky](https://github.com/Botspot/rpi_conky)
- NetworkManager (for `nmcli`)

## Installation
1. Clone the repository  
```
    cd $HOME
    git clone https://github.com/fredrege/conky-ethernet-monitor-rpi5.git
    cd conky-ethernet-monitor
```
2. Run the installer
```
chmod +x install.sh
./install.sh
```
3. Update Conky  
Open `.conkyrc` in your favorite editor (it's usually in the `$HOME` directory)  
	```
	nano $HOME/.conkyrc
	```
	Add this line within the file's `conky.text` markup to display the ethernet monitor:
	```
	conky.text = [[
	
	...
	
	${color #AAAAAA}Ethernet Status: $alignr ${execp cat /tmp/eth_status.txt}
	
	...
	
	]]
	```
	
	The monitor script will create `eth_status.txt`.
	
	Save and close `.conkyrc`. If `.conkyrc` was running, it will restart automatically. 
