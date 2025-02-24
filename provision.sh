#!/bin/bash

dnf update
dnf install -y git make golang unzip
git clone https://github.com/warewulf/warewulf.git
cd warewulf || exit 1
git checkout v4.5.8
make all
make install
