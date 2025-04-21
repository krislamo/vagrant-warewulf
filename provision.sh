#!/bin/bash

# Update and install packages
dnf install -y \
    git \
    make \
    golang \
    unzip \
    dhcp-server \
    ipxe-bootimgs-x86 \
    ipxe-bootimgs-aarch64 \
    tftp-server

# Build and install
git clone https://github.com/warewulf/warewulf.git
cd warewulf || exit 1
git checkout v4.6.0
make clean defaults \
    PREFIX=/usr \
    BINDIR=/usr/bin \
    SYSCONFDIR=/etc \
    DATADIR=/usr/share \
    LOCALSTATEDIR=/var/lib \
    SHAREDSTATEDIR=/var/lib \
    MANDIR=/usr/share/man \
    INFODIR=/usr/share/info \
    DOCDIR=/usr/share/doc \
    SRVDIR=/var/lib \
    TFTPDIR=/var/lib/tftpboot \
    SYSTEMDDIR=/usr/lib/systemd/system \
    BASHCOMPDIR=/etc/bash_completion.d/ \
    FIREWALLDDIR=/usr/lib/firewalld/services \
    WWCLIENTDIR=/warewulf
make all
make install

# Turn off firewalld and SELinux
systemctl disable --now firewalld
setenforce 0
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config

# Configure warewulfd
mkdir -p /etc/warewulf
cp /vagrant/warewulf.conf /etc/warewulf/warewulf.conf
systemctl enable warewulfd
systemctl start warewulfd

# Configure image and compute nodes
export PATH="$PATH:/usr/local/bin"
wwctl configure --all --verbose --debug
wwctl container import docker://ghcr.io/warewulf/warewulf-rockylinux:9 rocky9
wwctl container build rocky9
wwctl profile set --yes --image rocky9 "default"
wwctl profile set --yes --netdev eth1 --netmask 255.255.255.0 --gateway 192.168.200.254 "defaultd"
wwctl node add node1.cluster -I 192.168.200.101 --discoverable
wwctl node add node2.cluster -I 192.168.200.102 --discoverable
