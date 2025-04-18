# -*- mode: ruby -*-
# vi: set ft=ruby :

# Load override settings
require 'yaml'
settings_path = '.settings.yml'
settings = {}

if File.exist?(settings_path)
  settings = YAML.load_file(settings_path)
end

# Warewulf controller settings
CONTROL_BOX  = settings['CONTROL_BOX'] || 'rockylinux/9'
CONTROL_HOST = settings['CONTROL_BOX'] || 'warewulf'
CONTROL_CPU  = settings['CONTROL_CPU'] || 2
CONTROL_MEM  = settings['CONTROL_MEM'] || 4096

# Network settings
NETWORK_PREFIX  = settings['NETWORK_PREFIX']  || '192.168.200'
NETWORK_CONTROL = settings['NETWORK_CONTROL'] || "#{NETWORK_PREFIX}.254"
NETWORK_NETMASK = settings['NETWORK_NETMASK'] || '255.255.255.0'

# Compute nodes
COMPUTE_NODES     = settings['COMPUTE_NODES']     || 2
COMPUTE_CPU       = settings['COMPUTE_CPU']       || 2
COMPUTE_MEM       = settings['COMPUTE_MEM']       || 4096
COMPUTE_MACPREFIX = settings['COMPUTE_MACPREFIX'] || '52:54:00:00:00'


Vagrant.configure("2") do |config|
    config.vm.define "controller", primary: true do |controller|
        controller.vm.box = CONTROL_BOX
        controller.vm.hostname = CONTROL_HOST
        controller.vm.synced_folder ".", "/vagrant", type: "nfs", nfs_version: 4

        controller.vm.network "private_network",
            ip: NETWORK_CONTROL,
            netmask: NETWORK_NETMASK,
            libvirt__network_name: "pxe",
            libvirt__dhcp_enabled: false

        controller.vm.provider :libvirt do |libvirt|
            libvirt.cpus = CONTROL_CPU
            libvirt.memory = CONTROL_MEM
            # Doesn't boot without this
            libvirt.machine_virtual_size = 10
        end

        controller.vm.provision "shell", inline: <<-SHELL
            export NETWORK_CONTROL="#{NETWORK_CONTROL}"
            export NETWORK_NETMASK="#{NETWORK_NETMASK}"
            export COMPUTE_NODES="#{COMPUTE_NODES}"
            export COMPUTE_MACPREFIX="#{COMPUTE_MACPREFIX}"
            /bin/bash /vagrant/provision.sh
        SHELL
    end

    (1..COMPUTE_NODES).each do |count|
        config.vm.define "cn#{count}", autostart: false do |node|
            node.vm.hostname = "cn#{count}"
            node.vm.network "private_network",
                libvirt__network_name: "pxe",
                mac: "#{COMPUTE_MACPREFIX}:#{format('%02x', count)}"

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
