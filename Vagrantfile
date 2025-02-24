# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
    config.vm.box = "rockylinux/9"
    config.vm.hostname = "warewulf"
    config.vm.synced_folder ".", "/vagrant", type: "nfs", nfs_version: 4

    config.vm.provider :libvirt do |libvirt|
        libvirt.cpus = 2
        libvirt.memory = 4096
        libvirt.machine_virtual_size = 10
    end

    config.vm.provision "shell", path: "provision.sh"

end
