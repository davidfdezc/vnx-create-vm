# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.ssh.forward_x11 = true

  #config.vm.network :private_network, ip: "10.10.10.10"
  #config.vm.synced_folder ".", "/vagrant", id: "vagrant-root", owner: "vagrant", group: "vagrant"
  #config.vm.synced_folder "../../", "/home/svn-confaudit", id: "svn", owner: "ccn", group: "ccn"
  
  # Change locale
  #config.vm.provision :shell, :inline => <<-EOT
  #   echo 'LC_ALL="es_ES.UTF-8"'  >  /etc/default/locale
  #EOT

  bootstrap_args = ''
  IMGREPO='http://idefix.dit.upm.es/download/vagrant/'

  # Image repository naming schema:
  #     <dist_name>-<gui>-<vnx>-cloudimg-<arch>-vagrant-disk1-latest.box
  # Image repository naming schema examples:
  #   - trusty-cloudimg-amd64-vagrant-disk1-latest.box 
  #   - xenial-cloudimg-amd64-vagrant-disk1-latest.box
  #   - xenial-lubuntu-cloudimg-amd64-vagrant-disk1-latest.box 
  #   - xenial-lubuntucore-cloudimg-amd64-vagrant-disk1-latest.box
  #   - xenial-lubuntu-vnx-cloudimg-amd64-vagrant-disk1-latest.box
  #   - xenial-vnx-cloudimg-amd64-vagrant-disk1-latest.box -> /var/www/download/vagrant/xenial-vnx-cloudimg-amd64-vagrant-disk1-2016-09-04_23-51.box
  #   - zesty-lubuntu-vnx-cloudimg-amd64-vagrant-disk1-latest.box -> /var/www/download/vag

  case ENV['DIST']
  when "trusty", "vivid", "wily", "xenial", "zesty", "artful", "bionic"
    bootstrap_args = bootstrap_args + " -d " + ENV['DIST']
    dist = ENV['DIST']

  else # default
    bootstrap_args = bootstrap_args + " -d trusty"
    dist = "trusty"
  end

  case ENV['GUI']
  when "gnome", "lubuntu", "lubuntucore"
    bootstrap_args = bootstrap_args + " -g " + ENV['GUI']
    url_box_tag = ENV['GUI'] + "-"
    url_version_tag = ENV['GUI'] + "-"
  else 
    bootstrap_args = bootstrap_args + " -g no"
    url_box_tag = ""
    url_version_tag = ""
  end

  case ENV['VNX']
  when "yes"
    bootstrap_args = bootstrap_args + " -v yes"
    vnx = "vnx-"
  else 
    bootstrap_args = bootstrap_args + " -v no"
    vnx = ""
  end

  case ENV['ARCH']
  when "64"
    bootstrap_args = bootstrap_args + " -a 64"
    config.vm.box = dist + "64-" + url_box_tag + vnx + "updated"
    #config.vm.box_url = IMGREPO + dist + "-" + url_version_tag + vnx + "cloudimg-amd64-vagrant-disk1-latest.box"

  else
    bootstrap_args = bootstrap_args + " -a 32"
    config.vm.box = dist + "32-" + url_box_tag + vnx + "updated"
    #config.vm.box_url = IMGREPO + dist + "-" + url_version_tag + vnx + "cloudimg-i386-vagrant-disk1-latest.box"
  end

  config.ssh.forward_x11 = true
  config.ssh.insert_key = false
  #config.vm.network :private_network, ip: "10.11.11.2", :netmask => "255.255.255.252"

  # Change locale
  #config.vm.provision :shell, :inline => <<-EOT
  #   echo 'LC_ALL="es_ES.UTF-8"'  >  /etc/default/locale
  #EOT

  if ( ENV['HNAME'] == nil ) 
    # Set default value
    bootstrap_args = bootstrap_args + " -n vnx"
  else
    bootstrap_args = bootstrap_args + " -n #{ENV['HNAME']}"
  end

  if ( ENV['NEWUSER'] == nil ) 
    # Set default value
    bootstrap_args = bootstrap_args + " -u user"
  else
    bootstrap_args = bootstrap_args + " -u #{ENV['NEWUSER']}"
  end

  if ( ENV['NEWPASSWD'] == nil ) 
    # Set default value
    bootstrap_args = bootstrap_args + " -p xxxx"
  else
    bootstrap_args = bootstrap_args + " -p #{ENV['NEWPASSWD']}"
  end

  if ( ENV['VMLANG'] == nil ) 
    # Set default value
    bootstrap_args = bootstrap_args + " -l en"
  else
    bootstrap_args = bootstrap_args + " -l #{ENV['VMLANG']}"
  end

  if ( ENV['MEM'] == nil ) 
    # Set default value
    mem = "2048"
  else 
    mem = "#{ENV['MEM']}"
  end

  if ( ENV['VCPUS'] == nil ) 
    # Set default value
    vcpus = "2"
  else 
    vcpus = "#{ENV['VCPUS']}"
  end

  config.vm.provision :shell, :path => "bootstrap.sh", :args => bootstrap_args

  # To avoid problems with /vagrant mount (sometimes it is not mounted correctly),
  # we disable it and create our own mount
  config.vm.synced_folder ".", "/vagrant", disabled: true
  config.vm.synced_folder ".", "/install"

  config.vm.provider :virtualbox do |vb|
    vb.gui = true
    vb.customize [ "modifyvm", :id, "--memory", mem, "--cpus", vcpus ]
    #vb.customize [ "modifyvm", :id, "--cableconnected1", "on" ]
  end
end
