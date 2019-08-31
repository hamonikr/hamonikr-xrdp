#!/bin/bash

# xdrp setting tool for HamoniKR-ME (>= 1.4)
# Kevin Kim (root@hamonikr.org)
#
# Only Tested for Ubuntu 18.04 and HamoniKR
#
# help)
# $0 -s yes : apply sound redirection
# $0 -g yes : gdm patch
#

#---------------------------------------------------#
# Detecting if Parameters passed to script .... 
#---------------------------------------------------#

while getopts g:s: option 
do 
	case "${option}" 
		in 
		g) fixGDM=${OPTARG};; 
		s) fixSound=${OPTARG};; 
	esac 
done

#---------------------------------------------------#
# Script Version information Displayed              #
#---------------------------------------------------#

echo
/bin/echo -e "\e[1;36m !-------------------------------------------------------------!\e[0m"
/bin/echo -e "\e[1;36m ! Standard XRDP Installation Script  !\e[0m"
/bin/echo -e "\e[1;36m !-------------------------------------------------------------!\e[0m"
echo


#---------------------------------------------------#
# Function 1 - Install xRDP Software.... 
#---------------------------------------------------#

install_xrdp() 
{
	echo
	/bin/echo -e "\e[1;33m !---------------------------------------------!\e[0m"
	/bin/echo -e "\e[1;33m ! Installing XRDP Packages...Proceeding... ! \e[0m"
	/bin/echo -e "\e[1;33m !---------------------------------------------!\e[0m"
	echo
	sudo apt-get remove --purge -y xrdp xorgxrdp xrdp-pulseaudio-installer
	sudo apt-get install -y xrdp xorgxrdp
}

#---------------------------------------------------#
# Function 2 - Install Gnome Tweak Tool.... 
#---------------------------------------------------#

install_tweak() 
{
	echo
	/bin/echo -e "\e[1;33m !---------------------------------------------!\e[0m"
	/bin/echo -e "\e[1;33m ! Installing Gnome Tweak...Proceeding... ! \e[0m"
	/bin/echo -e "\e[1;33m !---------------------------------------------!\e[0m"
	echo
	sudo apt-get install gnome-tweak-tool -y
}

#--------------------------------------------------------------------#
# Fucntion 3 - Allow console Access ....(seems optional in u18.04)
#--------------------------------------------------------------------#

allow_console() 
{
	echo
	/bin/echo -e "\e[1;33m !---------------------------------------------!\e[0m"
	/bin/echo -e "\e[1;33m ! Granting Console Access...Proceeding... ! \e[0m"
	/bin/echo -e "\e[1;33m !---------------------------------------------!\e[0m"
	echo
	sudo sed -i 's/allowed_users=console/allowed_users=anybody/' /etc/X11/Xwrapper.config
}

#---------------------------------------------------#
# Function 4 - create policies exceptions .... 
#---------------------------------------------------#

create_polkit()
{
	echo
	/bin/echo -e "\e[1;33m !---------------------------------------------!\e[0m"
	/bin/echo -e "\e[1;33m ! Creating Polkit File...Proceeding... ! \e[0m"
	/bin/echo -e "\e[1;33m !---------------------------------------------!\e[0m"
	echo

	sudo cp -a ./etc /

}


#---------------------------------------------------#
# Function 5 - Fixing Theme and Extensions .... 
#---------------------------------------------------#

fix_theme()
{
	echo
	/bin/echo -e "\e[1;33m !---------------------------------------------!\e[0m"
	/bin/echo -e "\e[1;33m ! Fix Theme and extensions...Proceeding... !\e[0m"
	/bin/echo -e "\e[1;33m !---------------------------------------------!\e[0m"
	echo

	#Check if script has already run.... 
	if grep -xq "#fixGDM-by-Griffon" /etc/xrdp/startwm.sh; then
		echo "Skip theme fixing as script has run at least once..."
	else
		#Set xRDP session Theme to Ambiance and Icon to Humanity
		sudo sed -i.bak "4 a #fixGDM-by-Griffon\ngnome-shell-extension-tool -e ubuntu-appindicators@ubuntu.com\ngnome-shell-extension-tool -e ubuntu-dock@ubuntu.com\n\nif [ -f ~/.xrdp-fix-theme.txt ]; then\necho 'no action required'\nelse\ngsettings set org.gnome.desktop.interface gtk-theme 'Ambiance'\ngsettings set org.gnome.desktop.interface icon-theme 'Humanity'\necho 'check file for xrdp theme fix' >~/.xrdp-fix-theme.txt\nfi\n" /etc/xrdp/startwm.sh
	fi
	echo
}

#---------------------------------------------------#
# Function 6- Fixing GDM - As an Option .... 
#---------------------------------------------------#
fix_gdm()
{
	echo
	/bin/echo -e "\e[1;33m !---------------------------------------------!\e[0m"
	/bin/echo -e "\e[1;33m ! Fix for GDM Lock Screen color... !\e[0m"
	/bin/echo -e "\e[1;33m !---------------------------------------------!\e[0m"
	echo
	# Step 1 - Install prereqs for compilation later on
	sudo apt-get -y install libglib2.0-dev-bin
	sudo apt-get -y install libxml2-utils

	# extract gresource info (from url...)
	workdir=${HOME}/shell-theme
	if [ ! -d ${workdir}/theme ]; then
		mkdir -p ${workdir}/theme
		mkdir -p ${workdir}/theme/icons

	fi
	gst=/usr/share/gnome-shell/gnome-shell-theme.gresource

	for r in `gresource list $gst`; do
		gresource extract $gst $r >$workdir/${r#\/org\/gnome\/shell/}
	done

	/bin/echo -e "\e[1;33m |-| Creating XML File... \e[0m"
	# create the xml file 
	bash -c "cat >${workdir}/theme/gnome-shell-theme.gresource.xml" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<gresources>
<gresource prefix="/org/gnome/shell/theme">
<file>calendar-arrow-left.svg</file>
<file>calendar-arrow-right.svg</file>
<file>calendar-today.svg</file>
<file>checkbox-focused.svg</file>
<file>checkbox-off-focused.svg</file>
<file>checkbox-off.svg</file>
<file>checkbox.svg</file>
<file>close-window.svg</file>
<file>close.svg</file>
<file>corner-ripple-ltr.png</file>
<file>corner-ripple-rtl.png</file>
<file>dash-placeholder.svg</file>
<file>filter-selected-ltr.svg</file>
<file>filter-selected-rtl.svg</file>
<file>gnome-shell.css</file>
<file>gnome-shell-high-contrast.css</file>
<file>logged-in-indicator.svg</file>
<file>no-events.svg</file>
<file>no-notifications.svg</file>
<file>noise-texture.png</file>
<file>page-indicator-active.svg</file>
<file>page-indicator-inactive.svg</file>
<file>page-indicator-checked.svg</file>
<file>page-indicator-hover.svg</file>
<file>process-working.svg</file>
<file>running-indicator.svg</file>
<file>source-button-border.svg</file>
<file>summary-counter.svg</file>
<file>toggle-off-us.svg</file>
<file>toggle-off-intl.svg</file>
<file>toggle-on-hc.svg</file>
<file>toggle-on-us.svg</file>
<file>toggle-on-intl.svg</file>
<file>ws-switch-arrow-up.png</file>
<file>ws-switch-arrow-down.png</file>
</gresource>
</gresources>
EOF
cd ${workdir}/theme
/bin/echo -e "\e[1;33m |-| Modify Css... \e[0m"
sed -i -e 's/background: #2e3436/background: #2c00e1/g' ~/shell-theme/theme/gnome-shell.css

##Delete the file noise-texture.png (grey one)
rm ${workdir}/theme/noise-texture.png

/bin/echo -e "\e[1;33m |-| Download Purple image file... \e[0m"
#Download the noise-texture.png with purple background 
wget http://www.c-nergy.be/downloads/noise-texture.png

/bin/echo -e "\e[1;33m |-| Compile Resource File... \e[0m"
#Compile file and copy to correct location....
cd ${workdir}/theme
glib-compile-resources gnome-shell-theme.gresource.xml

/bin/echo -e "\e[1;33m |-| Copy file to target location... \e[0m"

# make a backup of the file and copy the file....
sudo cp /usr/share/gnome-shell/gnome-shell-theme.gresource /usr/share/gnome-shell/gnome-shell-theme.gresource.bak
sudo cp ${workdir}/theme/gnome-shell-theme.gresource /usr/share/gnome-shell/gnome-shell-theme.gresource
echo
}

#---------------------------------------------------------#
# Function 7 - Enable Sound Redirection - As an option.. #
#---------------------------------------------------------#
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
	echo

}

#--------------------------------------------------------------------------#
# -----------------------END Function Section -----------------#
#--------------------------------------------------------------------------#

#--------------------------------------------------------------------------#
#------------ MAIN SCRIPT SECTION -------------------# 
#--------------------------------------------------------------------------#

#---------------------------------------------------#
#-- Step 0 - Try to Detect Ubuntu Version.... 
#---------------------------------------------------#

version=$(lsb_release -sd) 
codename=$(lsb_release -sc)

# for hamonikr
version="Ubuntu 18.04"
codename="bionic"


echo
/bin/echo -e "\e[1;33m |-| Detecting Ubuntu version \e[0m"

if [[ "$version" = *"Ubuntu 18.04"* ]];
then
	/bin/echo -e "\e[1;32m |-| Ubuntu Version : $version\e[0m"
	echo
else
	echo
	/bin/echo -e "\e[1;31m !------------------------------------------------------------!\e[0m"
	/bin/echo -e "\e[1;31m ! Your system is not running Ubuntu 18.04 Edition and later !\e[0m"
	/bin/echo -e "\e[1;31m ! The script has been tested only on Ubuntu 18.04 and later !\e[0m"
	/bin/echo -e "\e[1;31m ! The script is exiting... !\e[0m" 
	/bin/echo -e "\e[1;31m !------------------------------------------------------------!\e[0m"
	echo
	exit
fi

/bin/echo -e "\e[1;33m   |-| Detecting Parameters        \e[0m"

#Detect if argument passed
if [ "$fixSound" = "yes" ]; 
then 
	/bin/echo -e "\e[1;32m       |-| Sound Redirection Option...: [YES]\e[0m"
else
	/bin/echo -e "\e[1;32m       |-| Sound Redirection Option...: [NO]\e[0m"
fi

if [ "$fixGDM" = "yes" ]; 
then 
	/bin/echo -e "\e[1;32m       |-| gdm fix Option.............: [YES]\e[0m"
else
	/bin/echo -e "\e[1;32m       |-| gdm fix Option.............: [NO]\e[0m"
fi
echo

#---------------------------------------------------------#
# Step 2 - Executing the installation & config tasks .... #
#---------------------------------------------------------#

echo
/bin/echo -e "\e[1;36m !-------------------------------------------------------------!\e[0m"
/bin/echo -e "\e[1;36m ! Installation Process starting.... !\e[0m"
/bin/echo -e "\e[1;36m !-------------------------------------------------------------!\e[0m"
echo
/bin/echo -e "\e[1;33m |-| Proceed with installation..... \e[0m"
echo

install_xrdp
install_tweak
allow_console
create_polkit
# fix_theme
enable_sound


if [ "$fixGDM" = "yes" ]; 
then 
	fix_gdm
fi

if [ "$fixSound" = "yes" ]; 
then 
	enable_sound
fi

# disable FuseMount
#sudo sed -i 's/FuseMountName=thinclient_drives/#FuseMountName=thinclient_drives/g' /etc/xrdp/sesman.ini 

#---------------------------------------------------#
# Step 3 - Credits .... 
#---------------------------------------------------#
echo
/bin/echo -e "\e[1;36m !-----------------------------------------------------------------------!\e[0m"
/bin/echo -e "\e[1;36m ! Installation Completed !\e[0m" 
/bin/echo -e "\e[1;36m ! Please test your xRDP configuration.A Reboot Might be required... !\e[0m"
/bin/echo -e "\e[1;36m !-----------------------------------------------------------------------!\e[0m"
echo
