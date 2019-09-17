#!/usr/bin/env bash

#
# VNX installation script for Vagrant VMs
# 
# Author: David Fernández (david.fernandez@upm.es)
#
# This file is part of the Virtual Networks over LinuX (VNX) Project distribution. 
# (www: http://www.dit.upm.es/vnx - e-mail: vnx@dit.upm.es) 
# 
# Departamento de Ingenieria de Sistemas Telematicos (DIT)
# Universidad Politecnica de Madrid
# SPAIN
#


INSTALLDIR="/install"

if [ $( which apt-fast ) ]; then 
    echo "-- Using apt-fast"
    APT_CMD=apt-fast
else 
    echo "-- Using apt-get"
    APT_CMD=apt-get
fi


#
# Default values
# Can be changed adding command line args
GUI=no		            # -g gnome|lubuntu|lubuntucore|no
HNAME=vnx               # -n hostname
NEWUSER=rdor            # -u username
PASSWD='xxxx'           # -p password
VMLANG=en_US.UTF-8      # -l xx
ARCH=32                 # -a 64|32
DIST=trusty             # -d trusty|vivid
VNX=no                  # -v yes|no

echo $0 $1 $2 $3 $4 $5 $6 $7 $8 $9 ${10} ${11} ${12}

while getopts ":g:u:p:n:l:a:d:v:" opt; do
    case "$opt" in
        g)
            GUI="$OPTARG" ;;
        u)
            NEWUSER="$OPTARG" ;;
        p)
            PASSWD="$OPTARG" ;;
        n)
            HNAME="$OPTARG" ;;
        l)
            VMLANG="$OPTARG" ;;
        a)
            ARCH="$OPTARG" ;;
        d)
            DIST="$OPTARG" ;;
        v)
            VNX="$OPTARG" ;;
    esac
done

echo "--"
echo "DIST=$DIST, ARCH=$ARCH, GUI=$GUI, NEWUSER=$NEWUSER, PASSWD=$PASSWD, HNAME=$HNAME, VMLANG=$VMLANG VNX=$VNX"
echo "--"

echo "--"
echo "---- Mount shared dir in /install:"
echo "--"

# Check if vboxsf kernel module is loaded/loadable
modprobe vboxsf 
if [ $? -ne 0 ]; then
    echo "--"
    echo "---- ERROR: Cannot load vboxsf module to mount install directory. Aborting provision."
    echo "--"
    exit 1
fi

# mount the install directory
mount -t vboxsf -o uid=`id -u vagrant`,gid=`getent group vagrant | cut -d: -f3` install $INSTALLDIR
if [ $? -ne 0 ]; then
    echo "--"
    echo "---- ERROR: Cannot mount /install directory. Aborting provision."
    echo "--"
    exit 1
fi

# Check that we can access the content of install directory
ls -l $INSTALLDIR/Vagrantfile
if [ $? -ne 0 ]; then
    echo "--"
    echo "---- ERROR: Cannot access $INSTALLDIR directory content. Aborting provision."
    echo "--"
    exit 1
else
    echo "---- $INSTALLDIR content:"
    ls -al $INSTALLDIR
    echo "----"
fi

# Add the mount to /etc/fstab
# We use the noauto option to avoid problems at startup. If the VM is started with the fstab entry 
# (without the noauto option) and the shared directory is not configured in VirtualBox, the virtual 
# machine does not start correctly, giving a "Welcome to emergency mode" message.
echo "install /install vboxsf uid=vagrant,gid=vagrant,noauto 0 0" >> /etc/fstab
# Add vboxsf module to /etc/modules
echo "vboxsf" >> /etc/modules

echo "--"
echo "---- Changing hostname:"
echo "--"

HNAME=$( echo $HNAME | sed -e 's/_//g' )   # Eliminate "_" from the hostname

echo $HNAME > /etc/hostname
hostname $HNAME
sed -i -e '/^127.0.1.1/d' /etc/hosts
sed -i -e "2i127.0.1.1\t$HNAME" /etc/hosts
#sed -i -e "s/127.0.1.1.*/127.0.1.1   $HNAME/" /etc/hosts

echo "--"
echo "-- Upgrading the system to latest packages versions and update locales:"
echo "--"
echo "--"
echo "-- Updating package list:"
echo "--"
export DEBIAN_FRONTEND=noninteractive
$APT_CMD update

LANG=${VMLANG}_${VMLANG^^}.UTF-8
echo "--"
echo "-- Setting locale to $LANG:"
echo "--"
$APT_CMD -y install language-pack-$VMLANG-base language-pack-$VMLANG
rm /etc/default/locale
update-locale LANG=$LANG LC_MESSAGES=POSIX

echo "--"
echo "-- Setting keyboard:"
echo "--"
sed -i -e "/exit 0/i/bin/loadkeys $VMLANG" /etc/rc.local
sed -i -e 's/XKBMODEL=.*/XKBMODEL="pc105"/' /etc/default/keyboard
sed -i -e 's/XKBLAYOUT=.*/XKBLAYOUT="es"/' /etc/default/keyboard

echo "--"
echo "-- Setting timezone:"
echo "--"
rm /etc/localtime
ln -s /usr/share/zoneinfo/Europe/Madrid /etc/localtime

echo "--"
echo "-- Upgrading packages:"
echo "--"
$APT_CMD -y dist-upgrade

echo "--"
echo "-- Creating new user $NEWUSER:"
echo "--"
useradd -m -p "$pass" -s "/bin/bash" $NEWUSER
[ $? -eq 0 ] && echo "User $NEWUSER added to the system" || echo "Failed to add $NEWUSER"
echo "$NEWUSER:$PASSWD" | chpasswd
adduser $NEWUSER sudo
echo "$NEWUSER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$NEWUSER

# Create ~/bin directory and add it to the PATH
mkdir -f /home/$NEWUSER/bin
sudo bash -c "echo 'PATH=\$PATH:/home/$NEWUSER/bin' >> /home/$NEWUSER/.bashrc "


#
# Installing GUI if requested
#
echo "-- GUI: $GUI"
if [ "$GUI" == "gnome" -o "$GUI" == "lubuntu" -o "$GUI" == "lubuntucore" ]; then 

  echo "--"
  echo "-- Installing GUI: $GUI"
  echo "--"
  #$APT_CMD -y install --no-install-recommends lubuntu-desktop
  if [ "$GUI" == "gnome" ]; then 

    #
    # GUI configuration for GNOME
    #
    $APT_CMD -y --no-install-recommends install ubuntu-desktop
    # Set autologin to the new created account
    sed -i -e 's/.*AutomaticLoginEnable =.*/AutomaticLoginEnable = true/' -e "s/.*AutomaticLogin =.*/AutomaticLogin = $NEWUSER/" /etc/gdm3/custom.conf
    # Disable screensaver (does not work)
    # su $NEWUSER gsettings set org.gnome.desktop.screensaver lock-enabled false

  elif [ "$GUI" == "lubuntu" -o "$GUI" == "lubuntucore" ]; then 

    #
    # GUI configuration for LXDE (lubuntu)
    #
    if [ "$GUI" == "lubuntu" ]; then 
      $APT_CMD -y --no-install-recommends install lubuntu-desktop
    elif [ "$GUI" == "lubuntucore" ]; then 
      $APT_CMD -y --no-install-recommends install lubuntu-core
    fi
    $APT_CMD -y remove network-manager

    # Disable screensaver
    #  mkdir -p /home/$NEWUSER/.config/autostart/
    #  cat >> /home/$NEWUSER/.config/autostart/screensaver-settings.desktop <<EOF
    #[Desktop Entry]
    #Name=Salvapantallas
    #Comment=Configurar los tiempos de espera del salvapantallas
    #Exec=xset s 0 dpms 0 0 0 -dpms
    #EOF
    #  cat /home/$NEWUSER/.config/autostart/screensaver-settings.desktop 
    chown -R $NEWUSER.$NEWUSER /home/$NEWUSER/
    # xset -dpms;xset s noblank in my .xinitrc

    # Set wallpaper
    WALLPAPER=vnx-dit-upm-fondo-1024.png
    WALLPAPERDIR=/usr/share/lubuntu/wallpapers/
    cd $WALLPAPERDIR
    wget http://idefix.dit.upm.es/vnx/logos/$WALLPAPER
    #mv $WALLPAPER lubuntu-default-wallpaper.png
    #mkdir -p /home/$NEWUSER/.config/pcmanfm/lubuntu/
    #sed -i -e 's/wallpaper=.*/wallpaper=/usr/share/lubuntu/wallpapers/vnx-fondo-1200.png/' /home/$NEWUSER/.config/pcmanfm/lubuntu/desktop-items-0.conf

    # Create script to config some desktop issues
    CFGDESK=/usr/local/bin/config_desktop
    CFGDESKFILE=/home/$NEWUSER/.config/pcmanfm/lubuntu/desktop-items-0.conf
    CFGLIBFMFILE=/home/$NEWUSER/.config/libfm/libfm.conf

    CFGSTORE=/home/$NEWUSER/tmp
    mkdir -p /home/$NEWUSER/tmp
    cp -a $INSTALLDIR/config/ $CFGSTORE

    echo "#!/bin/bash" > $CFGDESK
    echo "pcmanfm &" >> $CFGDESK
    #echo "PID=\$( echo \$! )" >> $CFGDESK
    echo "sleep 2" >> $CFGDESK
    echo "sed -i -e 's#wallpaper=.*#wallpaper=$WALLPAPERDIR/$WALLPAPER#' $CFGDESKFILE" >> $CFGDESK
    echo "sed -i -e 's#wallpaper_mode=.*#wallpaper_mode=center#' $CFGDESKFILE" >> $CFGDESK
    echo "sed -i -e 's/desktop_bg=.*/desktop_bg=#d9eafa/' $CFGDESKFILE" >> $CFGDESK
    # Config execution by double click
    echo "sed -i -e 's/quick_exec=.*/quick_exec=1/' $CFGLIBFMFILE" >> $CFGDESK
    # Copy desktop panel configuration
    echo "mkdir -p /home/$NEWUSER/.config/lxpanel/Lubuntu/panels/" >> $CFGDESK
    echo "cp $CFGSTORE/config/panel /home/$NEWUSER/.config/lxpanel/Lubuntu/panels/" >> $CFGDESK
    # Copy xfce4-terminal configuration
    echo "cp -a $CFGSTORE/config/terminal /home/$NEWUSER/.config/xfce4/" >> $CFGDESK
    # Disable screen locking
    echo "gsettings set apps.light-locker lock-after-screensaver 0" >> $CFGDESK
    echo "gsettings set apps.light-locker lock-on-suspend false" >> $CFGDESK
    echo "LOS=\$( gsettings get apps.light-locker lock-on-suspend )" >> $CFGDESK
    echo "while [ \$LOS == 'false' ]; do" >> $CFGDESK
    echo "  gsettings set apps.light-locker lock-on-suspend true" >> $CFGDESK
    echo "  sleep 1" >> $CFGDESK
    echo "  LOS=\$( gsettings get apps.light-locker lock-on-suspend )" >> $CFGDESK
    echo "done" >> $CFGDESK
    echo "yad --text '\n\n\n    Present login session will be finished.    \n\n    Login again to load new settings.    ' --no-buttons --center &">> $CFGDESK
    echo "sleep 5" >> $CFGDESK
    echo "pkill -SIGTERM -f lxsession" >> $CFGDESK

    #echo "kill \$PID" >> $CFGDESK

    chmod +x $CFGDESK

    # Set autologin to the new created account
    mkdir -p /etc/lightdm/lightdm.conf.d/
    echo "[SeatDefaults]" > /etc/lightdm/lightdm.conf.d/20-lubuntu.conf
    echo "autologin-user=$NEWUSER" >> /etc/lightdm/lightdm.conf.d/20-lubuntu.conf

  fi

  echo ""
  echo "Installing VBoxGuestAdditions..."
  echo ""
  echo "Installing packages required:"
  echo ""
  $APT_CMD -y install linux-headers-generic build-essential dkms
  VER=$( curl -s http://download.virtualbox.org/virtualbox/LATEST-STABLE.TXT )
  echo ""
  echo "Getting latest version of VBoxGuestAdditions for Linux: $VER"
  echo ""
  wget -nv http://download.virtualbox.org/virtualbox/$VER/VBoxGuestAdditions_$VER.iso
  mkdir /media/VBoxGuestAdditions
  mount -o loop,ro VBoxGuestAdditions_$VER.iso /media/VBoxGuestAdditions
  sh /media/VBoxGuestAdditions/VBoxLinuxAdditions.run
  rm VBoxGuestAdditions_$VER.iso
  umount /media/VBoxGuestAdditions
  rmdir /media/VBoxGuestAdditions

  # Add new user to vboxsf group to allow shared folders
  usermod -a -G vboxsf $NEWUSER

  # Optional: install sublime text editor
  #wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
  #apt-add-repository "deb https://download.sublimetext.com/ apt/stable/"
  #$APT_CMD -y install sublime-text

  echo ""
  echo "Installing open-vm-tools (for VMware):"
  echo ""
  $APT_CMD -y install open-vm-tools-desktop

fi

# Disable apport to avoid "System program problem detected"
sed -i -e 's/^enabled=1/enabled=0/' /etc/default/apport 

# Create script to config some desktop issues
CLEANHALT=/usr/local/bin/clean_and_halt
echo "#!/bin/bash" > $CLEANHALT
echo "" >> $CLEANHALT
echo "sudo deluser vagrant" >> $CLEANHALT
echo "sudo apt-get autoremove" >> $CLEANHALT
echo "sudo apt-get clean" >> $CLEANHALT
echo "sudo dd if=/dev/zero of=/zerofile bs=1M" >> $CLEANHALT
echo "sudo rm -f /zerofile" >> $CLEANHALT
echo "sudo rm -f /var/crash/*" >> $CLEANHALT
echo "sudo bash -c 'history -c'" >> $CLEANHALT
echo "history -c" >> $CLEANHALT
echo "sudo halt -p" >> $CLEANHALT
chmod +x $CLEANHALT

# remount the install directory. The mount seems to be lost after VBoxGuestAdditions are installed
mount -t vboxsf -o uid=`id -u vagrant`,gid=`getent group vagrant | cut -d: -f3` install $INSTALLDIR
if [ $? -ne 0 ]; then
    echo "--"
    echo "---- ERROR: Cannot mount /install directory. Aborting provision."
    echo "--"
    exit 1
fi
echo "----"
echo "---- $INSTALLDIR content:"
ls -al $INSTALLDIR
echo "----"

# Add sentences to /etc/profile to set DISPLAY variable to host ip address
# (needed for windows machines). 
#cat >> /etc/profile <<EOF
#if [ -z \$DISPLAY ]; then
# export DISPLAY="\$(ip route show default | head -1 | awk '{print \$3}'):0"
# #echo "Setting DISPLAY to \$DISPLAY"
#fi
#EOF

# In order to have X windows working after changing to root with "sudo su" 
# we have to use the "-p" option of su, that is, "sudo su -p".
# We create an alias:
cat >> /etc/bash.bashrc <<EOF
alias sudosu='sudo su -p'
EOF

echo "--"
echo "-- Configuring vim:"
echo "--"
VIMCFG=$(cat <<EOF
set tabstop=4
set shiftwidth=4
set expandtab
if has("autocmd")
  au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("\$") | exe "normal! g'\"" | endif
endif
colorscheme elflord
EOF
)
echo "$VIMCFG" >> /etc/vim/vimrc
tail -12 /etc/vim/vimrc

# enable bash completion in interactive shells
cat << EOF >> /etc/bash.bashrc

# enable bash completion in interactive shells
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi
EOF


#
# VNX Instalation
#
echo "--"
echo "-- Installing VNX:"
echo "--"

echo "--"
echo "---- Installing required packages:"
echo "--"

export DEBIAN_FRONTEND=noninteractive
$APT_CMD -y install \
  bash-completion bridge-utils curl eog expect genisoimage gnome-terminal \
  graphviz libappconfig-perl libdbi-perl liberror-perl libexception-class-perl \
  libfile-homedir-perl libio-pty-perl libmath-round-perl libnetaddr-ip-perl \
  libnet-ip-perl libnet-ipv6addr-perl libnet-pcap-perl libnet-telnet-perl \
  libreadonly-perl libswitch-perl libsys-virt-perl libterm-readline-perl-perl \
  libvirt-bin libxml-checker-perl libxml-dom-perl libxml-libxml-perl \
  libxml-parser-perl libxml-tidy-perl lxc lxc-templates net-tools \
  openvswitch-switch picocom pv qemu-kvm screen tree uml-utilities virt-manager \
  virt-viewer vlan w3m wmctrl xdotool xfce4-terminal xterm \
  linux-image-extra-virtual eog

echo "--"
echo "---- Installing VNX application:"
echo "--"
mkdir /tmp/vnx-update
cd /tmp/vnx-update
rm -rf /tmp/vnx-update/vnx-*
wget -nv http://vnx.dit.upm.es/vnx/vnx-latest.tgz
tar xfvz vnx-latest.tgz
cd vnx-*-*
./install_vnx

echo "--"
echo "---- Modifiying VNX config file (/etc/vnx.conf):"
echo "--"
mv /usr/share/vnx/etc/vnx.conf.sample /etc/vnx.conf
# Set svg viewer to eog
sed -i -e '/\[general\]/{:a;n;/^$/!ba;i\svg_viewer=eog' -e '}' /etc/vnx.conf
# Set console to xfce4-terminal
sed -i -e '/console_term/d' /etc/vnx.conf
sed -i -e '/\[general\]/{:a;n;/^$/!ba;i\console_term=xfce4-terminal' -e '}' /etc/vnx.conf
# Set exe_host_cmd to yes
sed -i -e 's/^exe_host_cmds.*/exe_host_cmds=yes/' /etc/vnx.conf
# Disable aa_unconfined
#sed -i -e 's/aa_unconfined=.*/aa_unconfined=no/' /etc/vnx.conf
# Set union_type to overlayfs
sed -i -e 's/^union_type.*/union_type = overlayfs/' /etc/vnx.conf
# Enable overlayfs_workdir_option
sed -i -e 's/^overlayfs_workdir_option.*/overlayfs_workdir_option=yes/' /etc/vnx.conf

echo "--"
echo "-- Installing additional packages:"
echo "--"
add-apt-repository -y ppa:webupd8team/y-ppa-manager
$APT_CMD update
$APT_CMD -y install yad nmap aptsh tinc file-roller gedit wireshark tshark traceroute

echo "--"
echo "---- Setting Wireshark capture permission for vagrant and $NEWUSER:"
echo "--"
addgroup wireshark
chgrp wireshark /usr/bin/dumpcap
chmod 750 /usr/bin/dumpcap
setcap cap_net_raw,cap_net_admin+eip /usr/bin/dumpcap
adduser $NEWUSER wireshark
#adduser vagrant wireshark

#echo "--"
#echo "---- Other $NEWUSER configs:"
#echo "--"
#echo "-- Changing vim color scheme..."
#echo "colorscheme elflord" >> /home/$NEWUSER/.vimrc

#
# Copy customizedir to VM
#
if [ -d "$INSTALLDIR/customizedir" ]; then
        cp -a $INSTALLDIR/customizedir /home/$NEWUSER/customizedir
        chown -R $NEWUSER.$NEWUSER /home/$NEWUSER/customizedir
fi

#
# Execute customization script if exists
#
if [ -f $INSTALLDIR/customize.sh ]; then
  echo "--"
  echo "---- Executing customization script"
  echo "--"
  source $INSTALLDIR/customize.sh
  $APT_CMD -y install $ADDITIONAL_PACKAGES
else
  echo "--"
  echo "---- No customization script found"
  echo "--"
fi

echo "--"
echo "-- Cleaning package caches:"
echo "--"
$APT_CMD -y autoremove
$APT_CMD clean

echo "-- Rebooting to finish installation..."
reboot

echo "----"
