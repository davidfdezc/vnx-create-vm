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

# List of additional packages to be installed (space separated list)
ADDITIONAL_PACKAGES='abiword chromium-browser nodejs id3 id3v2 ffmpeg'

echo "---- Installing additional packages"
sudo apt-get -y install $ADDITIONAL_PACKAGES

#
# Customization script. It may use the following environment variables (see others in bootstap.sh):
#
# HNAME   -> hostname
# NEWUSER -> username
# INSTALLDIR -> shared directory where host files are accesible

# Install sublime text editor
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
sudo apt-add-repository "deb https://download.sublimetext.com/ apt/stable/"
sudo apt install -y sublime-text



#echo "---- Copying VNX rootfs:"
#cd /usr/share/vnx/filesystems/
#/usr/bin/vnx_download_rootfs -n -l -r vnx_rootfs_lxc_ubuntu-16.04-v025 -y
#ln -s rootfs_lxc_ubuntu rootfs_lxc

#ls $INSTALLDIR/filesystems
#if [ $? -ne 0 ]; then
#    echo "--"
#    echo "---- ERROR: Cannot access filesystems directory under $INSTALLDIR/"
#    echo "--"
#    exit
#else
    # Copy rootfs
#    vnx_download_rootfs -r vnx_rootfs_lxc_ubuntu-16.04-v025.tgz -l -y

    #ROOTFSPATHNAME=`readlink -f $INSTALLDIR/filesystems/rootfs_lxc64`
    #ROOTFSNAME=`basename $ROOTFSPATHNAME`
    #CDIR=$(pwd)
    #echo "---- Uncompressing $ROOTFSPATHNAME.tgz to $CDIR"
    #tar xfpz $ROOTFSPATHNAME.tgz
    #rm -f rootfs_lxc rootfs_lxc_ubuntu rootfs_lxc-rdor
    #ln -s $ROOTFSNAME rootfs_lxc
    #ln -s $ROOTFSNAME rootfs_lxc64
    #ln -s $ROOTFSNAME rootfs_lxc_ubuntu64
    #ln -s $ROOTFSNAME rootfs_lxc64-rdor

    # Copy examples
    #if [ -d "$INSTALLDIR/examples" ]; then
    #    cp -a $INSTALLDIR/examples /home/$NEWUSER/Desktop/examples
    #    chown -R $NEWUSER.$NEWUSER /home/$NEWUSER/Desktop
    #fi
#fi

echo "----"
