VNX lab virtual machine creation scripts
----------------------------------------

Author: David Fernández (david.fernandez at upm.es)

1 - Introduction

These scripts were aimed to create Ubuntu based virtual machines with VNX installed to be used for 
laboratory exercises or project demostrations, although they can be also used to create other virtual
machines without VNX. The virtual machines are created using vagrant and VirtualBox.

The creation of the virtual machine is made in two steps. Firstly, a base VM is created by downloading 
the initial raw cloud image (bento/ubuntu-*), upgrading it to the latest package versions and installing 
the GUI and VNX package dependencies. This base VM is registered as a new vagrant box in the system (see 
it with "vagrant box list" command).

During the second step, the final VM is created by cloning the VM created in the first step and installing 
on it the additional packages and executing the customization commands specified in the customize.sh script.

The reason to divide the process in two steps is to accelerate the second step, which is often repeated 
a lot of times during the development. Moving all the slow package installation (mainly the GUI desktop 
package) to the first step, makes the second one much faster.

2 - Installation

- Requirements: Install Vagrant and VirtualBox

    apt-get install virtualbox vagrant

- Download scripts:

    git clone https://github.com/davidfdezc/vnx-create-vm.git

  The following files will be downloaded:
  - create-bento-ubuntu-box: script to create the base virtual machine
  - create-vm: script to create the final virtual machine
  - Vagrantfile: virtual machine vagrant configuration file
  - bootstrap.sh: final virtual machine provision script 
  - customize.sh: script to include customized code
  - shrink-vm: script to shrink virtual machine image before creating the OVA package
  - prepare-ova: script to create the OVA (*.ova) package with the final virtual machine

- Customize the installation by:

  - Creating a configuration file to specify the values of the basic installation variables:
      DIST: Ubuntu distribution version (trusty, vivid, wily, xenial, zesty)
      ARCH: 32 or 64 bits
      GUI: graphical interface (gnome, lubuntu, lubuntucore, no)
      VNX: install VNX (yes, no)
      HNAME: hostname 
      NEWUSER: username of main user
      NEWPASSWD: password of main user
      VMLANG: language (es, en, etc)
      MEM: memory assigned to VM in MB (Ex: 2048)
      VCPUS: numebre of cores assigned to VM (Ex: 4)

    For example:

      $ cat VNXLAB.conf 
      DIST=bionic
      ARCH=64
      GUI=lubuntu
      VNX=yes
      HNAME=vnx-vm
      NEWUSER=vnx
      NEWPASSWD=xxxx
      VMLANG=es 
      MEM=4096 
      VCPUS=2 

  - Editing customize.sh script and including customization commands to be run from inside the VM 
    during provision (see customize.sh example file)


3 - VM creation steps

- Create the base image. For example, to create a 64 bits Ubuntu 18.04 with gnome:

    cd base-vm
    ./create-bento-ubuntu-box -g gnome -a 64 -d bionic -v yes -f
    vagrant destroy
    cd ..

  Note: execute "./create-bento-ubuntu-box -h" to see the meaning of arguments.


- Create VM with:

    ./create-vm -c VNXLAB.conf

  Note: change VNXLAB.conf by the name of your config file.

- (Only for lubuntu GUI) Once the VM is created and started, open a shell and execute: 

    /usr/local/bin/config_desktop

  The login session will be automatically terminated. Login again to see the new desktop settings.

- Start firefox an close it (to avoid the firefox init page next time it is started)

- Do any other manual configuration you want to do to the VM.

- Clean up and halt the VM by executing:
 
    /usr/local/bin/clean_and_halt

  Note: this script takes some time as it fulls th filesystem with zeros to allow better compression.

- Shrink VM by executing:

    ./shrink-vm

- Do final configurations and convert to OVA format:

    ./prepare-ova <vm-name>

  For example:

    ./prepare-ova VNXLAB2019-v1


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
- sudo dd if=/dev/zero of=/zerofile bs=1M
- sudo rm -f /zerofile
- sudo history -c
- history -c
- sudo halt -p

