#!/usr/bin/env bash
#
# VNX installation script for Vagrant VMs
# 
# Author: David Fernández (david@dit.upm.es)
#
# This file is part of the Virtual Networks over LinuX (VNX) Project distribution. 
# (www: http://www.dit.upm.es/vnx - e-mail: vnx@dit.upm.es) 
# 
# Departamento de Ingenieria de Sistemas Telematicos (DIT)
# Universidad Politecnica de Madrid
# SPAIN
#

# List of additional packages to be installed (space separated list)
ADDITIONAL_PACKAGES=''

# move to the directory where the script is located
cd `dirname $0`
CDIR=$(pwd)

echo "-- Installing additional packages"
if [ "$ADDITIONAL_PACKAGES" ]: then 
    sudo apt-get -y install $ADDITIONAL_PACKAGES
fi

# Add aditional customization command here

echo "--"
echo "-- Finished"
