VNX lab virtual machine creation scripts
----------------------------------------

Author: David Fernández (david at dit.upm.es)

1 - Introduction

These scripts are aimed to create Ubuntu based virtual machines with VNX installed to be used for 
laboratory exercises or project demostrations. The virtual machines are created using vagrant and 
VirtualBox.

The creation of the virtual machine is made in two steps. First, a base VM is created by downloading 
the initial cloud image (bento/ubuntu-*) and upgrading it and installing the GUI and VNX package 
dependencies. This base VM is then registered as a new vagrant box and it is used as the starting 
point of the second step.

During the second step the final VM is created by installing additional packages and doing the 
all the customization by modifying the customize.sh script.

The reason to divide the process in two steps is to accelerate the second step, which is often repeated 
a lot of times during the development, by doing all the slow package installation and upgrading in 
the first step. 

2 - Installation

- Requirements: Install Vagrant and VirtualBox

    apt-get install virtualbox vagrant

- Download scripts:

    git clone https://github.com/davidfdezc/vnx-create-vm.git

  The following files will be downloaded:
  - create-bento-ubuntu-box: script to create the base virtual machine
  - create-vm: script to create the final virtual machine
  - Vagrantfile: virtual machina vagrant configuration file
  - bootstrap.sh: final virtual machine provision script 
  - customize.sh: script to include customized code
  - prepare-ova: script to create the OVF (*.ova) package with the final virtual machine

- Customize the installation by:

  - Editing "create-vm" and modify the basic installation variables:
      DIST: Ubuntu distribution version (trusty, vivid, wily, xenial, zesty)
      ARCH: 32 or 64 bits
      GUI: graphical interface (yes, no)
      VNX: install VNX (yes, no)
      HNAME: hostname 
      NEWUSER: username of main user
      NEWPASSWD: password of main user
      VMLANG: language (es, en, etc)
      MEM: memory assigned to VM in MB (Ex: 2048)
      VCPUS: numebre of cores assigned to VM (Ex: 4)

  - Editting customize.sh script and including customization commands to be run from inside the VM 
    during provision


3 - VM creation steps

- Create the base image. For example:

  ./create-ubuntu-box-bento -g full -a 64 -d zesty -v yes -f

- Create VM with:

  ./create-vm

- Once the VM is created and started, open a shell and execute: 

    /usr/local/bin/config_desktop. 

  The login session will be automatically terminated. Login again to see the new desktop settings.

- Start firefox an close it (to avoid the firefox init page next time it is started)

- Clean up and halt the VM:
 
    /usr/local/bin/clean_and_halt

- Do final configurations and convert to OVA format:

    ./prepare-ova <vm-name>

  For example:

    ./prepare-ova RDOR2017-v1


config_desktop tasks:
---------------------

- Change font size of xfce4-terminal to 10 pts (Preferences|Appearance)
- Add launchers to taskbar (terminal, firefox, wireshark)
- Change taskbar config to group windows (Pannel Applets| Taskbar)
- Configures file explorer to not ask for confirmation when double clicking on a script.
  Manually done by openning a file explorer (pcmanfm), going to "Edit/Preferences/General" and checking box 
  for "Don't ask options on launch executable file"
- Deactivate screen lock: Preferencias|Administrador de energía|Security -> Automatically lock the session = Never
  Deactivate also Lock screen when system is going for sleep

clean_and_halt tasks:
---------------------

- sudo deluser vagrant
- sudo apt-get autoremove
- sudo apt-get clean
- sudo history -c
- history -c
- sudo halt -p

