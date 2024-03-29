#!/bin/bash
#####################################################################################################
# Script_Name : hamonikr-xrdp-installer.sh
# Description : Perform xRDP installation on Ubuntu 22.04, HamoniKR 7 and perform
#               additional post configuration to improve end user experience
# Date : Mon, 18 Sep 2023 10:18:03 +0900
# written by : Kevin Kim
# WebSite :https://hamonikr.org
####################################################################################################

#---------------------------------------------------#
# Variables and Constants                           #
#---------------------------------------------------#

#--Automating Script versioning 
ScriptVer="1.4"

#--Detecting  OS Version 
version=$(lsb_release -sd)
codename=$(lsb_release -sc)
Release=$(lsb_release -sr)

RUID=$(who | awk 'FNR == 1 {print $1}')
#Define Dwnload variable to point to ~/Downloads folder of user running the script
Dwnload=$(sudo -u ${RUID} xdg-user-dir DOWNLOAD)

#Initialzing other variables
modetype="unknown"



#---------------------------------------------------------#
# Initial checks and Validation Process ....              #
#---------------------------------------------------------#

#-- Detect if multiple runs and install mode used..... 
echo
/bin/echo -e "\e[1;33m   |-| Checking if script has run at least once...        \e[0m"
if [ -f /etc/xrdp/xrdp-installer-check.log ]
then
	modetype=$(sed -n 1p /etc/xrdp/xrdp-installer-check.log)
	/bin/echo -e "\e[1;32m       |-| Script has already run. Detected mode...: $modetype\e[0m"
else 
	/bin/echo -e "\e[1;32m       |-| First run or xrdp-installer-check.log deleted. Detected mode : $modetype        \e[0m"
fi 

#--Detecting variable related to Desktop interface and Directory path (Experimental)
if [[ *"$XDG_SESSION_TYPE"* = *"tty"*  ]] 
then 
	##-- Detect if installation done via ssh connections 
	/bin/echo -e "\e[1;32m       |-| Detected Installation via ssh.... \e[0m"
	echo
	# Need new code to display DE Option available
	/bin/echo -e "\e[1;33m  !--------------------------------------------------------------!\e[0m"
	/bin/echo -e "\e[1;33m  ! Your are using the xrdp-installer script via ssh connection  !\e[0m"
	/bin/echo -e "\e[1;33m  ! You might need to create your ~/.xsessionrc file manually    !\e[0m"
	/bin/echo -e "\e[1;33m  !                                                              !\e[0m"
	/bin/echo -e "\e[1;33m  ! The script will proceed....but might not work !!             !\e[0m"             
	/bin/echo -e "\e[1;33m  !--------------------------------------------------------------!\e[0m"
	echo

    cnt=$(ls /usr/share/xsessions |  wc -l)
    echo $cnt 

    if [ "$cnt" -gt "1" ]
    then 
        PS3='Please specify which DE you are using...: '
        desk=($(ls /usr/share/xsessions | cut -d "." -f 1))
    
    select menu in "${desk[@]}";
    do
    echo -e "\nyou picked $menu ($REPLY)"
    break;
    
    done
        
    else
    desk=($(ls /usr/share/xsessions | cut -d "." -f 1))
    menu=$desk
    echo "Desktop seems to be based on....: " $menu
    fi

    case $menu in

    "ubuntu")
    DesktopVer="ubuntu:GNOME"
    SessionVer="ubuntu"
    #might needed not to loose FireFox Snap version 
    ConfDir="/usr/share/ubuntu:/usr/local/share/:/usr/share/:/var/lib/snapd/desktop"
    /bin/echo -e "\e[1;32m       |-| Session         : $SessionVer\e[0m"
    /bin/echo -e "\e[1;32m       |-| Desktop Version : $DesktopVer\e[0m"
    ;;

    "gnome")
    DesktopVer=""
    SessionVer=""
    /bin/echo -e "\e[1;32m       |-| Session         : $SessionVer\e[0m"
    /bin/echo -e "\e[1;32m       |-| Desktop Version : $DesktopVer\e[0m"
    ;;
    
    "budgie-desktop")
    DesktopVer="Budgie:GNOME" 
    /bin/echo -e "\e[1;32m       |-| Session         : $SessionVer\e[0m"
    /bin/echo -e "\e[1;32m       |-| Desktop Version : $DesktopVer\e[0m"
    ;;

    "plasma")
    DesktopVer="KDE"
    SessionVer=""
    /bin/echo -e "\e[1;32m       |-| Session         : $SessionVer\e[0m"
    /bin/echo -e "\e[1;32m       |-| Desktop Version : $DesktopVer\e[0m"
        ;;

    "pop")
    DesktopVer="pop:GNOME"
    SessionVer="pop"
    /bin/echo -e "\e[1;32m       |-| Session         : $SessionVer\e[0m"
    /bin/echo -e "\e[1;32m       |-| Desktop Version : $DesktopVer\e[0m"
    ;;
    
    "mate")
    DesktopVer="MATE"
    SessionVer=""	
    /bin/echo -e "\e[1;32m       |-| Session         : $SessionVer\e[0m"
    /bin/echo -e "\e[1;32m       |-| Desktop Version : $DesktopVer\e[0m"
    ;;
    
    "cinnamon2d")
    DesktopVer="X-Cinnamon"
    SessionVer=""	
    /bin/echo -e "\e[1;32m       |-| Session         : $SessionVer\e[0m"
    /bin/echo -e "\e[1;32m       |-| Desktop Version : $DesktopVer\e[0m"
    ;;

    "cinnamon2")
    DesktopVer="X-Cinnamon"
    SessionVer=""	
    /bin/echo -e "\e[1;32m       |-| Session         : $SessionVer\e[0m"
    /bin/echo -e "\e[1;32m       |-| Desktop Version : $DesktopVer\e[0m"
    ;;

    "xfce")
    DesktopVer="XFCE"
    SessionVer=""	
    /bin/echo -e "\e[1;32m       |-| Session         : $SessionVer\e[0m"
    /bin/echo -e "\e[1;32m       |-| Desktop Version : $DesktopVer\e[0m"
    ;;
        
    "lxqt")
    DesktopVer="LXQt"
    SessionVer=""	
    /bin/echo -e "\e[1;32m       |-| Session         : $SessionVer\e[0m"
    /bin/echo -e "\e[1;32m       |-| Desktop Version : $DesktopVer\e[0m"
    ;; 
    
    "LXDE")
    DesktopVer="LXDE"
    SessionVer=""	
    /bin/echo -e "\e[1;32m       |-| Session         : $SessionVer\e[0m"
    /bin/echo -e "\e[1;32m       |-| Desktop Version : $DesktopVer\e[0m"
    ;;  


    *)
    /bin/echo -e "\e[1;31m  !--------------------------------------------------------------!\e[0m"
    /bin/echo -e "\e[1;31m  ! Unable to detect a supported OS Version & Desktop interface  !\e[0m"
    /bin/echo -e "\e[1;31m  ! The script has been tested only on specific versions         !\e[0m"
    /bin/echo -e "\e[1;31m  !                                                              !\e[0m"
    /bin/echo -e "\e[1;31m  ! The script is exiting...                                     !\e[0m"             
    /bin/echo -e "\e[1;31m  !--------------------------------------------------------------!\e[0m"
    echo
    exit
    ;;
    esac

else
	##-- Installation is performed via an existing Desktop Interface...Trying to detect it....
	DesktopVer="$XDG_CURRENT_DESKTOP" 
	SessionVer="$GNOME_SHELL_SESSION_MODE"
	ConfDir="$XDG_DATA_DIRS"
fi

#--------------------------------------------------------------------------#
# -----------------------Function Section - DO NOT MODIFY -----------------#
#--------------------------------------------------------------------------#

#---------------------------------------------------#
# Function 0  - check for supported OS version  ....#
#---------------------------------------------------#

check_os()
{
echo
/bin/echo -e "\e[1;33m   |-| Detecting OS version        \e[0m"

case $version in

  *"Ubuntu 18.04"*)
   /bin/echo -e "\e[1;32m       |-| OS Version : $version\e[0m"
   /bin/echo -e "\e[1;32m       |-| Desktop Version : $DesktopVer\e[0m"
    ;;

   *"Ubuntu 20.04"*)
   /bin/echo -e "\e[1;32m       |-| OS Version : $version\e[0m"
   /bin/echo -e "\e[1;32m       |-| Desktop Version : $DesktopVer\e[0m"
    ;;
 
   *"Ubuntu 21.10"*)
   /bin/echo -e "\e[1;32m       |-| OS Version : $version\e[0m"
   /bin/echo -e "\e[1;32m       |-| Desktop Version : $DesktopVer\e[0m"
    ;;

 	*"Ubuntu 22.04"*)
   /bin/echo -e "\e[1;32m       |-| OS Version : $version\e[0m"
   /bin/echo -e "\e[1;32m       |-| Desktop Version : $DesktopVer\e[0m"
    ;;

   *"Pop!_OS 20.04"*)
   /bin/echo -e "\e[1;32m       |-| OS Version : $version\e[0m"
   /bin/echo -e "\e[1;32m       |-| Desktop Version : $DesktopVer\e[0m"
    ;;
 
   *"Pop!_OS 21.04"*)
   /bin/echo -e "\e[1;32m       |-| OS Version : $version\e[0m"
   /bin/echo -e "\e[1;32m       |-| Desktop Version : $DesktopVer\e[0m"
	;;
  
   *"Pop!_OS 21.10"*)
   /bin/echo -e "\e[1;32m       |-| OS Version : $version\e[0m"
   /bin/echo -e "\e[1;32m       |-| Desktop Version : $DesktopVer\e[0m"
	;;

  *"Debian"*)
   /bin/echo -e "\e[1;32m       |-| OS Version  : $version\e[0m"
   /bin/echo -e "\e[1;32m       |-| Desktop Version : $DesktopVer\e[0m"

   if [[ $Release = "11" ]] && [[ -z "$adv"  ]]
   then 
		#Check if Custom Install already performed...if yes, enable sound 
		if [[ $modetype = "custom" ]] && [[ $fixSound = "yes" ]]
		then 
      		/bin/echo -e "\e[1;32m       |-| Install Mode (Debian)   : Custom...Proceeding\e[0m"
			/bin/echo -e "\e[1;32m       |-| Enabling Sound (Debian) : .........Proceeding\e[0m"
		else	
			/bin/echo -e "\e[1;31m  !--------------------------------------------------------------!\e[0m"
			/bin/echo -e "\e[1;31m  ! You are running Debian 11 ! Please note that standard Mode   !\e[0m"
			/bin/echo -e "\e[1;31m  ! will not allow you to perform remote connection against      !\e[0m"
			/bin/echo -e "\e[1;31m  ! Gnome Desktop. This is a known Debian/xRDP issue             !\e[0m"
			/bin/echo -e "\e[1;31m  ! Use custom install mode                                      !\e[0m"
			/bin/echo -e "\e[1;31m  !                                                              !\e[0m"             
			/bin/echo -e "\e[1;31m  ! The script is exiting...                                     !\e[0m"             
			/bin/echo -e "\e[1;31m  !--------------------------------------------------------------!\e[0m"
			echo
			exit
		fi   
   else
	 /bin/echo -e "\e[1;32m       |-| Install Mode (Debian)  : Check Done...Proceeding\e[0m"
   fi 
   ;;

  *)
    /bin/echo -e "\e[1;31m  !--------------------------------------------------------------!\e[0m"
	/bin/echo -e "\e[1;31m  ! Your system is not running a supported version !             !\e[0m"
	/bin/echo -e "\e[1;31m  ! The script has been tested only on the following versions    !\e[0m"
	/bin/echo -e "\e[1;31m  ! Ubuntu 18.04.x/20.04.x/22.04/21.10/Debian 10/11              !\e[0m"
	/bin/echo -e "\e[1;31m  ! The script is exiting...                                     !\e[0m"             
	/bin/echo -e "\e[1;31m  !--------------------------------------------------------------!\e[0m"
	echo
	exit
	;;
esac
echo
}

#---------------------------------------------------#
# Function 1  - check xserver-xorg-core package....
#---------------------------------------------------#

check_hwe()
{
#Release=$(lsb_release -sr)
echo
/bin/echo -e "\e[1;33m |-| Detecting xserver-xorg-core package installed \e[0m"

xorg_no_hwe_install_status=$(dpkg-query -W -f ='${Status}\n' xserver-xorg-core 2>/dev/null)
xorg_hwe_install_status=$(dpkg-query -W -f ='${Status}\n' xserver-xorg-core-hwe-$Release 2>/dev/null) 

if [[ "$xorg_hwe_install_status" =~ \ installed$ ]]
then
# – hwe version is installed on the system
/bin/echo -e "\e[1;32m 	|-| xorg package version: xserver-xorg-core-hwe \e[0m"
HWE="yes"
elif [[ "$xorg_no_hwe_install_status" =~ \ installed$ ]]
then
/bin/echo -e "\e[1;32m 	|-| xorg package version: xserver-xorg-core \e[0m"
HWE="no"
else
/bin/echo -e "\e[1;31m 	|-| Error checking xserver-xorg-core flavour \e[0m"
exit 1
fi
}

#---------------------------------------------------#
# Function 2  - Version specific actions needed....
#---------------------------------------------------#

PrepOS()
{
echo 
/bin/echo -e "\e[1;33m   |-| Custom actions based on OS Version....       \e[0m" 

#Debian Specific - add in source backport package to download necessary packages - Debian Specific
if [[ *"$version"* = *"Debian"*  ]]
then
sudo sed -i 's/deb cdrom:/#deb cdrom:/' /etc/apt/sources.list
sudo apt-get update 
sudo apt-get install -y software-properties-common
sudo apt-add-repository -s -y 'deb http://deb.debian.org/debian '$codename'-backports main'
sudo apt-get update 

#--Needed to be created manually or compilation fails 
sudo mkdir /usr/local/lib/xrdp/
fi
#--End Debian Specific --# 

## POP!OS Color #363533
if [[ *"$version"* = *"Debian"*  ]]
then
	CustomPix="hamonikr.bmp"
    CustomColor="276baa"
else 
	CustomPix="hamonikr.bmp"
	CustomColor="276baa"
fi
}

############################################################################
# INSTALLATION MODE : STANDARD
############################################################################

#---------------------------------------------------#
# Function 3  - Install xRDP Software....
#---------------------------------------------------#

install_xrdp()
{
echo 
/bin/echo -e "\e[1;33m   |-| Installing xRDP packages       \e[0m"
echo 
if [[ $HWE = "yes" ]] && [[ "$version" = *"Ubuntu 18.04"* ]];
then
	sudo apt-get install xrdp -y
	sudo apt-get install xorgxrdp-hwe-18.04
else
    sudo apt-get install xrdp -y
fi
}

############################################################################
# ADVANCED INSTALLATION MODE : CUSTOM INSTALLATION
############################################################################

#---------------------------------------------------#
# Function 4 - Install Prereqs...
#---------------------------------------------------#

install_prereqs() {

echo 
/bin/echo -e "\e[1;33m   |-| Installing prerequisites packages       \e[0m" 
echo

#Install packages
sudo apt-get -y install git
sudo apt-get -y install libx11-dev libxfixes-dev libssl-dev libpam0g-dev libtool libjpeg-dev flex bison gettext autoconf libxml-parser-perl libfuse-dev xsltproc libxrandr-dev python3-libxml2 nasm fuse pkg-config git intltool checkinstall
echo

#-- check if no error during Installation of missing packages
if [ $? -eq 0 ]
then 
/bin/echo -e "\e[1;33m   |-| Preprequesites installation successfully       \e[0m"
else 
echo
echo
/bin/echo -e "\e[1;31m   !---------------------------------------------!\e[0m"
/bin/echo -e "\e[1;31m   !   Error while installing prereqs            !\e[0m"
/bin/echo -e "\e[1;31m   !   The Script is exiting....                 !\e[0m"
/bin/echo -e "\e[1;31m   !---------------------------------------------!\e[0m"
exit
fi

#-- check if hwe stack needed or not 
if [ $HWE = "yes" ];
then
	# - xorg-hwe-* to be installed
	/bin/echo -e "\e[1;32m       |-| xorg package version: xserver-xorg-core-hwe-$Release \e[0m"
	sudo apt-get install -y xserver-xorg-dev-hwe-$Release xserver-xorg-core-hwe-$Release	
else
	#-no-hwe
	/bin/echo -e "\e[1;32m       |-| xorg package version: xserver-xorg-core \e[0m"
	echo
	sudo apt-get install -y xserver-xorg-dev xserver-xorg-core
fi
}

#---------------------------------------------------#
# Function 5 - Download XRDP Binaries... 
#---------------------------------------------------#
get_binaries() { 
echo 
/bin/echo -e "\e[1;33m   |-| Downloading xRDP Binaries...Proceeding     \e[0m" 
echo

#cd ~/Downloads
# Dwnload=$(xdg-user-dir DOWNLOAD)
Dwnload=$(sudo -u ${RUID} xdg-user-dir DOWNLOAD)
cd $Dwnload

#Check if xrdp folder already exists.  if yes; delete it and download again in order to get latest version
if [ -d "$Dwnload/xrdp" ] 
then
	sudo rm -rf xrdp
fi

#Check if xorgxrdp folder already exists.  if yes; delete it and download again in order to get latest version
if [ -d "$Dwnload/xorgxrdp" ] 
then
	sudo rm -rf xorgxrdp
fi

## -- Download the xrdp latest files
echo
/bin/echo -e "\e[1;32m       |-|  Downloading xRDP Binaries.....     \e[0m" 
echo
git clone https://github.com/neutrinolabs/xrdp.git
echo 
/bin/echo -e "\e[1;32m       |-|  Downloading xorgxrdp Binaries...     \e[0m" 
echo
git clone https://github.com/neutrinolabs/xorgxrdp.git

}

#---------------------------------------------------#
# Function 6 - compiling xrdp... 
#---------------------------------------------------#
compile_source() { 
echo 
/bin/echo -e "\e[1;33m   |-| Compiling xRDP Binaries...Proceeding     \e[0m" 
echo

#cd ~/Downloads/xrdp
cd $Dwnload/xrdp

#Get the release version automatically
pkgver=$(git describe  --abbrev=0 --tags  | cut -dv -f2)

sudo ./bootstrap
sudo ./configure --enable-fuse --enable-jpeg --enable-rfxcodec
sudo make

#-- check if no error during compilation 
if [ $? -eq 0 ]
then 
echo
/bin/echo -e "\e[1;32m       |-|  Make Operation Completed successfully....xRDP     \e[0m" 
echo
else 
echo
/bin/echo -e "\e[1;31m   !---------------------------------------------!\e[0m"
/bin/echo -e "\e[1;31m   !   Error while Executing make                !\e[0m"
/bin/echo -e "\e[1;31m   !   The Script is exiting....                 !\e[0m"
/bin/echo -e "\e[1;31m   !---------------------------------------------!\e[0m"
exit
fi
sudo checkinstall --pkgname=xrdp --pkgversion=$pkgver --pkgrelease=1 --default

#xorgxrdp package compilation
echo
/bin/echo -e "\e[1;32m       |-|  Make Operation Completed successfully....xorgxrdp     \e[0m" 
echo

#cd ~/Downloads/xorgxrdp 
cd $Dwnload/xorgxrdp

#Get the release version automatically
pkgver=$(git describe  --abbrev=0 --tags  | cut -dv -f2)

sudo ./bootstrap 
sudo ./configure 
sudo make

# check if no error during compilation 
if [ $? -eq 0 ]
then 
echo
/bin/echo -e "\e[1;33m   |-| Compilation Completed successfully...Proceeding    \e[0m"
echo
else 
echo
/bin/echo -e "\e[1;31m   !---------------------------------------------!\e[0m"
/bin/echo -e "\e[1;31m   !   Error while Executing make                !\e[0m"
/bin/echo -e "\e[1;31m   !   The Script is exiting....                 !\e[0m"
/bin/echo -e "\e[1;31m   !---------------------------------------------!\e[0m"
exit
fi
sudo checkinstall --pkgname=xorgxrdp --pkgversion=1:$pkgver --pkgrelease=1 --default
}

#---------------------------------------------------#
# Function 7 - create services .... 
#---------------------------------------------------# 
enable_service() {
echo
/bin/echo -e "\e[1;33m   |-| Creating and configuring xRDP services    \e[0m"
echo
sudo systemctl daemon-reload
sudo systemctl enable xrdp.service
sudo systemctl enable xrdp-sesman.service
sudo systemctl start xrdp

}

############################################################################
# COMMON FUNCTIONS - WHATEVER INSTALLATION MODE - Version Specific !!!
############################################################################

#--------------------------------------------------------------------------#
# Function 8 - Install Tweaks Utilty if Gnome desktop used (Optional) .... #
#--------------------------------------------------------------------------# 
install_tweak() 
{
echo
/bin/echo -e "\e[1;33m   |-| Checking if Tweaks needs to be installed....    \e[0m"
if [[ "$DesktopVer" != *"GNOME"* ]] 
then
/bin/echo -e "\e[1;32m       |-|  Gnome Tweaks not needed...Proceeding...     \e[0m" 
echo
else
/bin/echo -e "\e[1;32m       |-|  Installing Gnome Tweaks Utility...Proceeding... \e[0m" 
echo
    sudo apt-get install gnome-tweak-tool -y
fi
}

#--------------------------------------------------------------------#
# Fucntion 9 - Allow console Access ....(seems optional in u18.04)
#--------------------------------------------------------------------#

allow_console() 
{
echo
/bin/echo -e "\e[1;33m   |-| Configuring Allow Console Access...    \e[0m"
echo
# Checking if Xwrapper file exists
if [ -f /etc/X11/Xwrapper.config ]
then
sudo sed -i 's/allowed_users=console/allowed_users=anybody/' /etc/X11/Xwrapper.config
else
	sudo bash -c "cat >/etc/X11/Xwrapper.config" <<EOF
	allowed_users=anybody
EOF
fi
}

#---------------------------------------------------#
# Function 10 - create policies exceptions .... 
#---------------------------------------------------#
create_polkit()
{
echo
/bin/echo -e "\e[1;33m   |-| Creating Polkit exceptions rules...    \e[0m"
echo

#Allow wifi scan on Ubuntu 22.04 (https://devicetests.com/fix-wifi-scans-focal-fossa)
sudo bash -c "cat >/etc/polkit-1/localauthority/50-local.d/47-allow.wifi-scan.pkla" <<EOF
[Allow Wifi Scan]
Identity=unix-user:*
Action=org.freedesktop.NetworkManager.wifi.scan;org.freedesktop.NetworkManager.enable-disable-wifi;org.freedesktop.NetworkManager.settings.modify.own;org.freedesktop.NetworkManager.settings.modify.system;org.freedesktop.NetworkManager.network-control
ResultAny=yes
ResultInactive=yes
ResultActive=yes
EOF

#All Ubuntu versions,Debian Version, Pop OS version
sudo bash -c "cat >/etc/polkit-1/localauthority/50-local.d/45-allow.colord.pkla" <<EOF
[Allow Colord all Users]
Identity=unix-user:*
Action=org.freedesktop.color-manager.create-device;org.freedesktop.color-manager.create-profile;org.freedesktop.color-manager.delete-device;org.freedesktop.color-manager.delete-profile;org.freedesktop.color-manager.modify-device;org.freedesktop.color-manager.modify-profile
ResultAny=no
ResultInactive=no
ResultActive=yes
EOF

#Not to apply to Ubuntu 18.04 version but to others....This caused an issue on Ubuntu 18.04 
if [[  "$version" !=  *"Ubuntu 18.04"* ]]; 
then
sudo bash -c "cat >/etc/polkit-1/localauthority/50-local.d/46-allow-update-repo.pkla" <<EOF
[Allow Package Management all Users]
Identity=unix-user:*
Action=org.freedesktop.packagekit.system-sources-refresh;org.freedesktop.packagekit.system-network-proxy-configure
ResultAny=yes
ResultInactive=yes
ResultActive=yes
EOF
fi

#-- KDE Desktop Specific  - can be detected only at run time of the script 
if [ "$DesktopVer" = "KDE" ];
then
sudo bash -c "cat >/etc/polkit-1/localauthority/50-local.d/47-allow-networkd.pkla" <<EOF
[Allow Network Control all Users]
Identity=unix-user:*
Action=org.freedesktop.NetworkManager.network-control
ResultAny=no
ResultInactive=no
ResultActive=yes
EOF
fi

}



#---------------------------------------------------#
# Function 12 - Fixing Theme and Extensions .... 
#---------------------------------------------------#

fix_theme()
{
echo
/bin/echo -e "\e[1;33m   |-| Fixing Themes and Extensions....    \e[0m"
echo

# Checking if script has run already 
if [ -f /etc/xrdp/startwm.sh.griffon ]
then
sudo rm /etc/xrdp/startwm.sh
sudo mv /etc/xrdp/startwm.sh.griffon /etc/xrdp/startwm.sh
fi 

#Backup the file before modifying it
sudo cp /etc/xrdp/startwm.sh /etc/xrdp/startwm.sh.griffon
echo

# Custom code for Budgie Desktop 
if [[ "$DesktopVer" == *"Budgie"* ]]
then 
sudo sed -i "4 a #Improved Look n Feel Method\ncat <<EOF > ~/.xsessionrc\nbudgie-desktop\nexport GNOME_SHELL_SESSION_MODE=$SessionVer\nexport XDG_CURRENT_DESKTOP=$DesktopVer\nexport XDG_DATA_DIRS=$ConfDir\nEOF\n" /etc/xrdp/startwm.sh
else
sudo sed -i "4 a #Improved Look n Feel Method\ncat <<EOF > ~/.xsessionrc\nexport GNOME_SHELL_SESSION_MODE=$SessionVer\nexport XDG_CURRENT_DESKTOP=$DesktopVer\nexport XDG_DATA_DIRS=$ConfDir\nEOF\n" /etc/xrdp/startwm.sh
fi
echo

}

#---------------------------------------------------#
# Function 12 - Enable Sound Redirection .... 
#---------------------------------------------------#
enable_sound()
{
echo
/bin/echo -e "\e[1;33m   |-| Enabling Sound Redirection....    \e[0m"
echo

pulsever=$(pulseaudio --version | awk '{print $2}')

/bin/echo -e "\e[1;32m       |-| Install additional packages..     \e[0m" 

# Version Specific - adding source and correct pulseaudio version for Debian !!!  
if [[ *"$version"* = *"Debian"*  ]]
then
# Step 0 - Install Some PreReqs
/bin/echo -e "\e[1;32m       	|-| Install dev tools used to compile sound modules..     \e[0m" 
echo
sudo apt-get install libconfig-dev -y
sudo apt-get install git libpulse-dev autoconf m4 intltool build-essential dpkg-dev libtool libsndfile-dev libcap-dev -y libjson-c-dev
sudo apt build-dep pulseaudio -y
else 
# Step 1 - Enable Source Code Repository
/bin/echo -e "\e[1;32m      	|-| Adding Source Code Repository..     \e[0m"
echo 
sudo apt-add-repository -s -y 'deb http://archive.ubuntu.com/ubuntu/ '$codename' main restricted'
sudo apt-add-repository -s -y 'deb http://archive.ubuntu.com/ubuntu/ '$codename' restricted universe main multiverse'
sudo apt-add-repository -s -y 'deb http://archive.ubuntu.com/ubuntu/ '$codename'-updates restricted universe main multiverse'
sudo apt-add-repository -s -y 'deb http://archive.ubuntu.com/ubuntu/ '$codename'-backports main restricted universe multiverse'
sudo apt-add-repository -s -y 'deb http://archive.ubuntu.com/ubuntu/ '$codename'-security main restricted universe main multiverse'
sudo apt-get update
# Step 2 - Install Some PreReqs
sudo apt-get install git libpulse-dev autoconf m4 intltool build-essential dpkg-dev libtool libsndfile-dev libcap-dev -y libjson-c-dev
sudo apt build-dep pulseaudio -y
fi
echo
/bin/echo -e "\e[1;32m       |-| Download pulseaudio sources files..     \e[0m" 
# Step 3 -  Download pulseaudio source in /tmp directory - Debian source repo should be already enabled
cd /tmp
apt source pulseaudio
/bin/echo -e "\e[1;32m       |-| Compile pulseaudio sources files..     \e[0m" 

# Step 4 - Compile PulseAudio based on OS version & PulseAudio Version
cd /tmp/pulseaudio-$pulsever*
PulsePath=$(pwd)

cd "$PulsePath"
    if [ -x ./configure ]; then
        #if pulseaudio version <15.0, then autotools will be used (legacy) 
        ./configure
    elif [ -f ./meson.build ]; then
          #if pulseaudio version >15.0, then meson tools will be used (new)
        sudo meson --prefix=$PulsePath build
        sudo ninja -C build install
    fi

# step 5 - Create xrdp sound modules
cd /tmp
/bin/echo -e "\e[1;32m       |-| Compiling and building xRDP Sound modules...     \e[0m" 
git clone https://github.com/neutrinolabs/pulseaudio-module-xrdp.git
cd pulseaudio-module-xrdp
./bootstrap 
./configure PULSE_DIR=$PulsePath
make
#this will install modules in /usr/lib/pulse* directory
sudo make install
}

#---------------------------------------------------#
# Function 13 - Custom xRDP Login Screen .... 
#---------------------------------------------------#
custom_login()
{

echo 
/bin/echo -e "\e[1;33m   |-| Customizing xRDP login screen       \e[0m" 
Dwnload=$(sudo -u ${RUID} xdg-user-dir DOWNLOAD)
cd $Dwnload

#Check if script has run once...
if [ -f /etc/xrdp/xrdp.ini.griffon ]
then
sudo rm /etc/xrdp/xrdp.ini
sudo mv /etc/xrdp/xrdp.ini.griffon /etc/xrdp/xrdp.ini
fi 

#Backup file 
sudo cp /etc/xrdp/xrdp.ini /etc/xrdp/xrdp.ini.griffon

#chek if file exists if not - download it.... 
if [ -f "$CustomPix" ]
then
	/bin/echo -e "\e[1;32m       |-| necessary file already available...skipping   \e[0m"
else
	/bin/echo -e "\e[1;32m       |-| Downloading additional file...: logo_xrdp image   \e[0m"
	wget https://raw.githubusercontent.com/hamonikr/hamonikr-xrdp/master/usr/share/xrdp/"$CustomPix"
fi

#Check where to copy the logo file
if [ -d "/usr/local/share/xrdp" ] 
then
    echo
	sudo cp $CustomPix /usr/local/share/xrdp
    sudo sed -i "s/ls_logo_filename=/ls_logo_filename=\/usr\/local\/share\/xrdp\/$CustomPix/g" /etc/xrdp/xrdp.ini
else
    sudo cp $CustomPix /usr/share/xrdp
	sudo sed -i "s/ls_logo_filename=/ls_logo_filename=\/usr\/share\/xrdp\/$CustomPix/g" /etc/xrdp/xrdp.ini
fi


sudo sed -i 's/ls_height=430/ls_height=390/' /etc/xrdp/xrdp.ini
sudo sed -i 's/#white=ffffff/white=dedede/' /etc/xrdp/xrdp.ini
sudo sed -i 's/#ls_title=My Login Title/ls_title=Remote Desktop for Linux/' /etc/xrdp/xrdp.ini
sudo sed -i "s/ls_top_window_bg_color=009cb5/ls_top_window_bg_color=$CustomColor/" /etc/xrdp/xrdp.ini
sudo sed -i 's/ls_bg_color=dedede/ls_bg_color=f7e6c6/' /etc/xrdp/xrdp.ini
sudo sed -i 's/ls_label_x_pos=30/ls_label_x_pos=20/' /etc/xrdp/xrdp.ini
sudo sed -i 's/ls_label_width=65/ls_label_width=70/' /etc/xrdp/xrdp.ini
sudo sed -i 's/ls_btn_ok_x_pos=142/ls_btn_ok_x_pos=112/' /etc/xrdp/xrdp.ini
sudo sed -i 's/ls_btn_ok_y_pos=370/ls_btn_ok_y_pos=330/' /etc/xrdp/xrdp.ini
sudo sed -i 's/ls_btn_cancel_x_pos=237/ls_btn_cancel_x_pos=207/' /etc/xrdp/xrdp.ini
sudo sed -i 's/ls_btn_cancel_y_pos=370/ls_btn_cancel_y_pos=330/' /etc/xrdp/xrdp.ini
}

#---------------------------------------------------#
# Function 14 - Fix SSL Minor Issue .... 
#---------------------------------------------------#
fix_ssl() 
{ 
echo 
/bin/echo -e "\e[1;33m   |-| Fixing SSL Permissions settings...       \e[0m" 
echo 
if id -Gn xrdp | grep ssl-cert 
then 
/bin/echo -e "\e[1;32m   !--xrdp already member ssl-cert...Skipping ---!\e[0m" 
else
	sudo adduser xrdp ssl-cert 
fi
}

#---------------------------------------------------#
# Function 15 - Fixing env variables in XRDP .... 
#---------------------------------------------------#
fix_env()
{
echo 
/bin/echo -e "\e[1;33m   |-| Fixing xRDP env Variables...       \e[0m" 
echo 
#Add this line to /etc/pam.d/xrdp-sesman if not present
if grep -Fxq "session required pam_env.so readenv=1 user_readenv=0" /etc/pam.d/xrdp-sesman 
   then
            echo "Env settings already set"
   else
		sudo sed -i '1 a session required pam_env.so readenv=1 user_readenv=0' /etc/pam.d/xrdp-sesman
 fi
echo 
/bin/echo -e "\e[1;33m   |-| Fixing HamoniKR Settings...       \e[0m" 
echo  
# xrdp.ini 
sudo wget -O /etc/xrdp/xrdp.ini https://gist.githubusercontent.com/chaeya/0ea3abff7545548b353e963124c6fda0/raw/0eede5dbf602a796c297dfa10a65049c7cf9d247/xrdp.ini
# sesman.ini 
sudo wget -O /etc/xrdp/sesman.ini https://gist.githubusercontent.com/chaeya/455af93542484b044b1eca4cee856086/raw/9e6bc9e34200b8b42c356bd63673e5ea1b2ea42c/sesman.ini
# startwm.sh 
sudo wget -O /etc/xrdp/startwm.sh https://gist.githubusercontent.com/chaeya/55ea089d9db59cc90c3ce65a36182ca4/raw/ba8839ac3429bf748246aed1cf3b3b7b7c4ba8cd/startwm.sh
sudo chmod +x /etc/xrdp/startwm.sh
}

#---------------------------------------------------#
# Function 17 - Removing XRDP Packages .... 
#---------------------------------------------------#
remove_xrdp()
{
echo 
/bin/echo -e "\e[1;33m   !---------------------------------------------!\e[0m" 
/bin/echo -e "\e[1;33m   ! Removing xRDP Packages...                   !\e[0m" 
/bin/echo -e "\e[1;33m   !---------------------------------------------!\e[0m" 
echo 

#remove the xrdplog file created by the script 
sudo rm /etc/xrdp/xrdp-installer-check.log

#----remove xrdp package
sudo systemctl stop xrdp
sudo systemctl disable xrdp
sudo apt-get autoremove xrdp -y
sudo apt-get purge xrdp -y

#---remove xorgxrdp
sudo systemctl stop xorgxrdp
sudo systemctl disable xorgxrdp

if [[ $HWE = "yes" ]] && [[ "$version" = *"Ubuntu 18.04"* ]];
then
	sudo apt-get autoremove xorgxrdp-hwe-18.04 -y 
	sudo apt-get purge xorgxrdp-hwe-18.04 -y
else
    sudo apt-get autoremove xorgxrdp -y 
	sudo apt-get purge xorgxrdp -y
fi

#---Cleanup files 

#Remove xrdp folder
if [ -d "$Dwnload/xrdp" ] 
then
	sudo rm -rf xrdp
fi

#Remove xorgxrdp folder
if [ -d "$Dwnload/xorgxrdp" ] 
then
	sudo rm -rf xorgxrdp
fi

#Remove custom xrdp logo file
if [ -f "$Dwnload/$CustomPix" ] 
then
	sudo rm -f  "$Dwnload/$CustomPix"
fi

sudo systemctl daemon-reload

}

sh_credits()
{
echo
/bin/echo -e "\e[1;36m   !----------------------------------------------------------------!\e[0m"
/bin/echo -e "\e[1;36m   ! Installation Completed...Please test your xRDP configuration   !\e[0m" 
/bin/echo -e "\e[1;36m   ! If Sound option selected, shutdown your machine completely     !\e[0m"
/bin/echo -e "\e[1;36m   ! start it again to have sound working as expected               !\e[0m"
/bin/echo -e "\e[1;36m   !                                                                !\e[0m"
/bin/echo -e "\e[1;36m   ! Credits : Written by Griffon - April 2022                      !\e[0m"
/bin/echo -e "\e[1;36m   !           www.c-nergy.be -xrdp-installer-v$ScriptVer.sh             !\e[0m"
/bin/echo -e "\e[1;36m   !           ver $ScriptVer                                            !\e[0m"
/bin/echo -e "\e[1;36m   !----------------------------------------------------------------!\e[0m"
echo
}


#---------------------------------------------------#
# SECTION FOR OPTIMIZING CODE USAGE...              #
#---------------------------------------------------#

install_common()
{
install_tweak	
allow_console
create_polkit
fix_theme
fix_ssl
fix_env
}

install_custom()
{
install_prereqs
get_binaries
compile_source
enable_service

}

#--------------------------------------------------------------------------#
# -----------------------END Function Section             -----------------#
#--------------------------------------------------------------------------#

#--------------------------------------------------------------------------#
#------------                 MAIN SCRIPT SECTION       -------------------# 
#--------------------------------------------------------------------------#

#---------------------------------------------------#
# Script Version information Displayed              #
#---------------------------------------------------#

echo
/bin/echo -e "\e[1;36m   !-----------------------------------------------------------------!\e[0m"
/bin/echo -e "\e[1;36m   !   xrdp-installer-$ScriptVer Script                                     !\e[0m"
/bin/echo -e "\e[1;36m   !   Support Ubuntu and Debian Distribution                        !\e[0m"
/bin/echo -e "\e[1;36m   !   Written by Griffon - April 2022  -  www.c-nergy.be            !\e[0m"
/bin/echo -e "\e[1;36m   !                                                                 !\e[0m"
/bin/echo -e "\e[1;36m   !   For Help and Syntax, type ./xrdp-installer-$ScriptVer.sh -h   !\e[0m"
/bin/echo -e "\e[1;36m   !                                                                 !\e[0m"
/bin/echo -e "\e[1;36m   !-----------------------------------------------------------------!\e[0m"
echo

#----------------------------------------------------------#
# Step 0 -Detecting if Parameters passed to script ....    #
#----------------------------------------------------------#
case "$#" in
  0) 
    fixSound="yes" 
    fixlogin="yes"  
    ;;
  *) 
    for arg in "$@"
        do
            #Help Menu Requested
            if [ "$arg" == "--help" ] || [ "$arg" == "-h" ]
            then
                        echo "Usage Syntax and Examples"
                        echo
                        echo " --custom or -c           custom xRDP install (compilation from sources)"
                        echo " --loginscreen or -l      customize xRDP login screen"
                        echo " --remove or -r           removing xRDP packages"
                        echo " --sound or -s            enable sound redirection in xRDP"
                        echo
                        echo "example                                                      "
                        echo     
                        echo " ./xrdp-installer-$ScriptVer.sh -c -s  custom install with sound redirection"
                        echo " ./xrdp-installer-$ScriptVer.sh -l     standard install with custom login screen"
                        echo " ./xrdp-installer-$ScriptVer.sh        standard install no additional features"
                        echo
                        exit
            fi
        
            if [ "$arg" == "--sound" ] || [ "$arg" == "-s" ]
            then
                fixSound="yes" 				
            fi 

            if [ "$arg" == "--loginscreen" ] || [ "$arg" == "-l" ]
            then
                fixlogin="yes"
            fi

            if [ "$arg" == "--custom" ] || [ "$arg" == "-c" ]
            then
                adv="yes"	
            fi

            if [ "$arg" == "--remove" ] || [ "$arg" == "-r" ]
            then
                removal="yes"		
            fi
        done
        ;;
esac


#--------------------------------------------------------------------------------#
#-- Step 0 - Check that the script is run as normal user and not as root....
#-------------------------------------------------------------------------------#

# if [[ $EUID -ne 0 ]]; then
# 	/bin/echo -e "\e[1;36m   !-------------------------------------------------------------!\e[0m"
# 	/bin/echo -e "\e[1;36m   !  Standard user detected....Proceeding....                   !\e[0m"
# 	/bin/echo -e "\e[1;36m   !-------------------------------------------------------------!\e[0m"
# else
# 	echo
# 	/bin/echo -e "\e[1;31m   !-------------------------------------------------------------!\e[0m"
# 	/bin/echo -e "\e[1;31m   !  Script launched with sudo command. Script will not run...  !\e[0m"
# 	/bin/echo -e "\e[1;31m   !  Run script a standard user account (no sudo). When needed  !\e[0m"
# 	/bin/echo -e "\e[1;31m   !  script will be prompted for password during execution      !\e[0m"
# 	/bin/echo -e "\e[1;31m   !                                                             !\e[0m"
# 	/bin/echo -e "\e[1;31m   !  Exiting Script - No Install Performed !!!                  !\e[0m"
# 	/bin/echo -e "\e[1;31m   !-------------------------------------------------------------!\e[0m"
# 	echo
# 	#sh_credits
# 	exit
# fi

#---------------------------------------------------#
#-- Step 1 - Try to Detect Ubuntu Version....       #
#---------------------------------------------------#

check_os

#--------------------------------------------------------#
#-- Step 2 - Try to detect if HWE Stack needed or not....#
#--------------------------------------------------------#

check_hwe

#--------------------------------------------------------------------------------#
#-- Step 3 - Check if Removal Option Selected
#--------------------------------------------------------------------------------#

if [ "$removal" = "yes" ];
then
	remove_xrdp
	echo
	sh_credits
	exit
fi



#---------------------------------------------------------------------------------------
#- Detect Standard vs custom install mode and additional options...
#----------------------------------------------------------------------------------------

	if [ "$adv" = "yes" ];
	then
		echo
		/bin/echo -e "\e[1;33m   |-| custom installation mode detected.        \e[0m"
		
		if [ $modetype = "custom" ];
		then 
			/bin/echo -e "\e[1;36m           |-| xrdp already installed - custom mode....skipping xrdp install        \e[0m"
			PrepOS
		else 
			/bin/echo -e "\e[1;36m           |-| Proceed custom xrdp installation packages and customization tasks      \e[0m"
			PrepOS
			install_custom
			install_common
		
			#create the file used a detection method 
			sudo touch /etc/xrdp/xrdp-installer-check.log
			sudo bash -c 'echo "custom" >/etc/xrdp/xrdp-installer-check.log'
		fi		

	else
		echo
			/bin/echo -e "\e[1;33m   |-| Additional checks Std vs Custom Mode..       \e[0m"
		if [ $modetype = "standard" ];
		then 
			/bin/echo -e "\e[1;35m           |-| xrdp already installed - standard mode....skipping install  \e[0m"
			PrepOS
		elif [ $modetype = "custom" ]
        then 
        	/bin/echo -e "\e[1;35m           |-| Checking for additional parameters"
		else
			/bin/echo -e "\e[1;32m       |-| Proceed standard xrdp installation packages and customization tasks      \e[0m"
			PrepOS
			install_xrdp
			install_common
			
			#create the file 
			sudo touch /etc/xrdp/xrdp-installer-check.log
			sudo bash -c 'echo "standard" >/etc/xrdp/xrdp-installer-check.log'
		fi
	fi  #end if Adv option

#---------------------------------------------------------------------------------------
#- Check for Additional Options selected 
#----------------------------------------------------------------------------------------

if [ "$fixSound" = "yes" ]; 
then 
		enable_sound      
fi

if [ "$fixlogin" = "yes" ]; 
then
	echo
	custom_login
fi



#---------------------------------------------------------------------------------------
#- show Credits and finishing script
#--------------------------------------------------------------------------------------- 

sh_credits 
