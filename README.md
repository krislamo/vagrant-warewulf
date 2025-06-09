# Vagrant Warewulf
This repository contains Vagrant configuration using the libvirt provider to
create a virtual Warewulf environment for cluster management and provisioning.

## Prerequisites

- Vagrant
- Vagrant's Libvirt Provider
    - Working NFS Synced Folder


## Getting Started
1. Boot and provision the Warewulf controller

       vagrant up

2. Boot the first compute node after the controller is installed

       vagrant up node1

    - Wait for the node to completely boot (monitor via VM console)

3. Rebuild the node's overlay

       vagrant ssh -c "sudo wwctl overlay build node1.cluster"

4. Reboot the virtual compute node

       vagrant halt node1 && vagrant up node1

4. Login to node1 from the controller

       vagrant ssh -c "sudo ssh node1"

#### Vagrant overrides in .settings.yml
- `COMPUTE_NUM`
    - Default: `2`
    - Number of compute nodes to create (provision script only configures first 2)
- `COMPUTE_CPU`
    - Default: `2`
    - CPU cores allocated to each compute node
- `COMPUTE_MEM`
    - Default: `4096`
    - RAM in MB allocated to each compute node

## Copyright and License
Copyright (C) 2025  Kris Lamoureux

This program is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation, version 3 of the License.

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with
this program. If not, see <https://www.gnu.org/licenses/>.