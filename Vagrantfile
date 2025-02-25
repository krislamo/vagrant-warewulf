# -*- mode: ruby -*-
# vi: set ft=ruby :

NODES = 2

Vagrant.configure("2") do |config|
    config.vm.define "controller", primary: true do |controller|
        controller.vm.box = "rockylinux/9"
        controller.vm.hostname = "warewulf"
        controller.vm.synced_folder ".", "/vagrant", type: "nfs", nfs_version: 4

        controller.vm.network "private_network",
            ip: "192.168.200.254",
            netmask: "255.255.255.0",
            libvirt__network_name: "pxe",
            libvirt__dhcp_enabled: false

        controller.vm.provider :libvirt do |libvirt|
            libvirt.cpus = 2
            libvirt.memory = 4096
            # Doesn't boot without this
            libvirt.machine_virtual_size = 10
        end

        controller.vm.provision "shell", path: "provision.sh"
    end

    (1..NODES).each do |count|
        config.vm.define "node#{count}", autostart: false do |node|
            node.vm.hostname = "node#{count}"
            node.vm.network "private_network",
                libvirt__network_name: "pxe"

            node.vm.provider :libvirt do |libvirt|
                libvirt.cpus = 2
                libvirt.memory = 4096
                # PXE boot
                boot_network = {'network' => 'pxe'}
                libvirt.boot boot_network
            end
        end
    end
end
