# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'
settings_path = '.settings.yml'
settings = {}

if File.exist?(settings_path)
  settings = YAML.load_file(settings_path)
end

COMPUTE_NUM = settings['COMPUTE_NUM'] || 2
COMPUTE_CPU = settings['COMPUTE_CPU'] || 2
COMPUTE_MEM = settings['COMPUTE_MEM'] || 4096

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
            libvirt.machine_virtual_size = 100
        end

        # Expand XFS rootfs
        config.vm.provision "shell", inline: <<-SHELL
            set -xe
            df -h /
            dnf install -y cloud-utils-growpart
            PART="$(findmnt -n -o SOURCE /)"
            DISK="$(lsblk -n -o PKNAME "$PART")"
            NUM="$(lsblk -n -o KNAME "$PART" | sed 's/.*[^0-9]//')"
            growpart "/dev/$DISK" "$NUM" && \
            xfs_growfs /
            df -h /
        SHELL

        controller.vm.provision "shell", path: "provision.sh"
    end

    (1..COMPUTE_NUM).each do |count|
        config.vm.define "node#{count}", autostart: false do |node|
            node.vm.hostname = "node#{count}"
            node.vm.network "private_network",
                libvirt__network_name: "pxe"

            node.vm.provider :libvirt do |libvirt|
                libvirt.cpus = COMPUTE_CPU
                libvirt.memory = COMPUTE_MEM
                # PXE boot
                boot_network = {'network' => 'pxe'}
                libvirt.boot boot_network
            end
        end
    end
end
