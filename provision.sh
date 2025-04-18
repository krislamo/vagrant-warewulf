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
git checkout v4.5.8
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
wwctl configure --all
wwctl container import docker://ghcr.io/warewulf/warewulf-rockylinux:9 rocky9
wwctl container build rocky9
wwctl profile set --yes --container rocky9 "default"
wwctl profile set --yes --netdev eth1 \
	--netmask "$NETWORK_NETMASK" \
	--gateway "$NETWORK_GATEWAY" "default"

# Add compute nodes with MAC-based addressing
for ((i=1; i<=COMPUTE_NODES; i++)); do
	NODE_IP="192.168.200.$i"
	NODE_MAC="${COMPUTE_MACPREFIX}:$(printf '%02x' $i)"
	wwctl node add cn${i} -I "$NODE_IP" --hwaddr "$NODE_MAC"
	wwctl overlay build "cn${i}"
	echo "Added node cn${i} $NODE_IP ($NODE_MAC)"
done
