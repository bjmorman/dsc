# -*- mode: ruby -*-
# vi: set ft=ruby :


Vagrant.configure("2") do |config|

  config.vm.define "win2012-pull-1" do |vmconfig|
    vmconfig.vm.box = "devopsgroup-io/windows_server-2012r2-standard-amd64-nocm"
    vmconfig.vm.guest = :windows
    vmconfig.vm.communicator = :winrm

    vmconfig.vm.hostname = 'win2012-pull-1'
    vmconfig.vm.network "private_network", ip: "10.0.2.11"
    vmconfig.vm.network "forwarded_port", guest: 3389, host: 3301

    vmconfig.vm.synced_folder "./", "/vagrant"

    vmconfig.vm.provider :virtualbox do |vb|
      vb.gui = false
      vb.memory = 1536
    end

    #vmconfig.vm.provision "shell", path: "scripts/provision-2008-nodes.ps1"

  end

  config.vm.define "win2012-wsus-1" do |vmconfig|
    vmconfig.vm.box = "devopsgroup-io/windows_server-2012r2-standard-amd64-nocm"
    vmconfig.vm.guest = :windows
    vmconfig.vm.communicator = :winrm

    vmconfig.vm.hostname = 'win2012-wsus-1'
    vmconfig.vm.network "private_network", ip: "10.0.2.12"
    vmconfig.vm.network "forwarded_port", guest: 3389, host: 3302

    vmconfig.vm.synced_folder "./", "/vagrant"

    vmconfig.vm.provider :virtualbox do |vb|
      vb.gui = false
      vb.memory = 1536
    end

    #vmconfig.vm.provision "shell", path: "scripts/provision-2008-nodes.ps1"

  end

end


