#!/bin/bash

# xdrp setting tool for HamoniKR-ME (>= 1.4)
# Kevin Kim (root@hamonikr.org)
#
# hamonikr-xrdp
# xdrp setting tool for HamoniKR-ME (>= 1.4)
# Copyright (C) 2019 Kevin Kim (root@hamonikr.org)
# - enable sound redirection
# - enable clipboard (file copy and paste)
# - compress transfer packet
# - performance turning
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

WORKDIR=$PWD

echo
/bin/echo -e "\e[1;36m !-------------------------------------------------------------!\e[0m"
/bin/echo -e "\e[1;36m ! 하모니카용 XRDP Patch v1.0 !\e[0m"
/bin/echo -e "\e[1;36m !-------------------------------------------------------------!\e[0m"
echo

install_xrdp() 
{
	echo
	/bin/echo -e "\e[1;33m !---------------------------------------------!\e[0m"
	/bin/echo -e "\e[1;33m ! 기존의 XRDP 패키지를 삭제하고 재 설치합니다. \e[0m"
	/bin/echo -e "\e[1;33m !---------------------------------------------!\e[0m"
	echo

	# remove previous install
	sudo apt-get update	
	sudo systemctl stop xrdp
	sudo apt-get remove --purge -y xrdp xorgxrdp xrdp-pulseaudio-installer
	sudo apt-get -y autoremove
	sudo rm -rf /usr/sbin/xrdp /usr/lib/xrdp /etc/xrdp /usr/local/lib/xrdp /usr/share/xrdp /usr/share/man/man8/xrdp.8
	sudo rm -rf  /var/lib/xrdp-pulseaudio-installer/{module-xrdp-sink.so,module-xrdp-source.so}
	sudo rm -rf /usr/lib/pulse-11.1/modules/{module-xrdp-sink.so,module-xrdp-source.so}

	sudo apt-get install -y xrdp xorgxrdp
	sudo apt-get install -y autoconf libtool nasm libfuse-dev libmp3lame-dev libfdk-aac-dev libjpeg-turbo8 libopus-dev
    
	git clone https://github.com/neutrinolabs/xrdp.git
	cd xrdp
	sudo ./bootstrap
	
	sudo ./configure --prefix=/usr --bindir=/usr/bin --sysconfdir=/etc/xrdp --enable-fuse --enable-jpeg --enable-rfxcodec --enable-mp3lame --enable-fdkaac --enable-pixman --enable-vsock --enable-tjpeg=/usr/lib/x86_64-linux-gnu --enable-opus

	sudo make
	sudo make install  
}

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
	/bin/echo -e "\e[1;33m ! 원격 접속에 필요한 정책을 설정합니다.. ! \e[0m"
	/bin/echo -e "\e[1;33m !---------------------------------------------!\e[0m"
	echo

	sudo cp -r $WORKDIR/etc /
	sudo cp -r $WORKDIR/etc/skel/.config/autostart/keyboardsetting.desktop /home/*/.config/autostart/
}

enable_sound()
{
	echo
	/bin/echo -e "\e[1;33m !---------------------------------------------!\e[0m"
	/bin/echo -e "\e[1;33m !  Sound Redirection 기능을 설치합니다.       !\e[0m"
	/bin/echo -e "\e[1;33m !---------------------------------------------!\e[0m"
	echo

	# Step 1 - Install xrdp-pulseaudio-installer package
	sudo apt-get install -y xrdp-pulseaudio-installer

	# Step 2 - Enable Source Code Repository
	sudo cp -r $WORKDIR/etc /
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
	sudo install -t "/usr/lib/pulse-$pulsever/modules" -D -m 644 *.so        
	echo

}

echo
/bin/echo -e "\e[1;36m !-------------------------------------------------------------!\e[0m"
/bin/echo -e "\e[1;36m !  하모니카에서 원격접속 환경을 설치합니다..... !\e[0m"
/bin/echo -e "\e[1;36m !-------------------------------------------------------------!\e[0m"
echo
/bin/echo -e "\e[1;33m |-| Proceed with installation..... \e[0m"
echo

# Install Process
install_xrdp
sudo apt install -y xorgxrdp
allow_console
create_polkit
enable_sound

# post settings

# 하모니카에서 테스트 된 설정 파일들 반영
sudo cp -r $WORKDIR/usr $WORKDIR/etc /
sudo chown root:root /etc /usr

# 키보드 사용을 위한 설정 
localectl --no-convert set-x11-keymap kr pc105 kr106
sudo xrdp-genkeymap /etc/xrdp/km-e0010412.ini

# disable screensaver
cinnamon-screensaver-command --exit
gsettings set org.cinnamon.settings-daemon.plugins.power sleep-display-ac "0"
gsettings set org.cinnamon.settings-daemon.plugins.power sleep-inactive-ac-timeout "0"

sudo systemctl daemon-reload
sudo systemctl enable xrdp.service
sudo systemctl enable xrdp-sesman.service

echo
/bin/echo -e "\e[1;36m !-----------------------------------------------------------------------!\e[0m"
/bin/echo -e "\e[1;36m ! 원격접속을 위한 프로그램 설치가 완료되었습니다. !\e[0m" 
/bin/echo -e "\e[1;36m ! 잠시 후 시스템을 재시작 합니다.... !\e[0m"
/bin/echo -e "\e[1;36m ! 원격접속 서버의 자동 로그인이 설정되어 있는 경우 해제해주세요. !\e[0m"
/bin/echo -e "\e[1;36m !-----------------------------------------------------------------------!\e[0m"
echo
echo "System will be Restart..."
echo "-------------------------"
sleep 5
sudo shutdown -r now
