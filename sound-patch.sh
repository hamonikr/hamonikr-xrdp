#!/bin/bash

# xdrp setting tool for HamoniKR-ME (>= 1.4)
# Kevin Kim (root@hamonikr.org)
#
# Only Tested for HamoniKR

allow_console() 
{
	echo
	/bin/echo -e "\e[1;33m !---------------------------------------------!\e[0m"
	/bin/echo -e "\e[1;33m ! Granting Console Access...Proceeding... ! \e[0m"
	/bin/echo -e "\e[1;33m !---------------------------------------------!\e[0m"
	echo
	sudo sed -i 's/allowed_users=console/allowed_users=anybody/' /etc/X11/Xwrapper.config
}

create_polkit()
{
	echo
	/bin/echo -e "\e[1;33m !---------------------------------------------!\e[0m"
	/bin/echo -e "\e[1;33m ! Creating Polkit File...Proceeding... ! \e[0m"
	/bin/echo -e "\e[1;33m !---------------------------------------------!\e[0m"
	echo

	sudo cp -a ./etc /

}

enable_sound()
{
	echo
	/bin/echo -e "\e[1;33m   !---------------------------------------------!\e[0m"
	/bin/echo -e "\e[1;33m   !   Enabling Sound Redirection...             !\e[0m"
	/bin/echo -e "\e[1;33m   !---------------------------------------------!\e[0m"
	echo

	# Step 1 - Install xrdp-pulseaudio-installer package
	sudo apt-get install xrdp-pulseaudio-installer -y

	# Step 2 - Enable Source Code Repository
	sudo cp -a ./etc /
	sudo apt-get update

	# Step 3 - Download pulseaudio source in /tmp directory
	cd /tmp
	sudo apt source pulseaudio

	# Step 4 - Compile
	pulsever=$(pulseaudio --version | awk '{print $2}')
	cd /tmp/pulseaudio-$pulsever
	sudo ./configure

	# Step 5 - Create xrdp sound modules
	cd /usr/src/xrdp-pulseaudio-installer
	sudo make PULSE_DIR="/tmp/pulseaudio-$pulsever"

	# Step 6 - copy files to correct location
	sudo install -t "/var/lib/xrdp-pulseaudio-installer" -D -m 644 *.so
	sudo install -t "/usr/lib/pulse-11.1/modules" -D -m 644 *.so    
	echo

}

echo
/bin/echo -e "\e[1;36m !-------------------------------------------------------------!\e[0m"
/bin/echo -e "\e[1;36m ! Installation Process starting.... !\e[0m"
/bin/echo -e "\e[1;36m !-------------------------------------------------------------!\e[0m"
echo
/bin/echo -e "\e[1;33m |-| Proceed with installation..... \e[0m"
echo

allow_console
create_polkit
enable_sound

echo
/bin/echo -e "\e[1;36m !-----------------------------------------------------------------------!\e[0m"
/bin/echo -e "\e[1;36m ! Installation Completed !\e[0m" 
/bin/echo -e "\e[1;36m ! Please test your xRDP configuration.A Reboot Might be required... !\e[0m"
/bin/echo -e "\e[1;36m !-----------------------------------------------------------------------!\e[0m"
echo
