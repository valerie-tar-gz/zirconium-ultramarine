#!/usr/bin/env bash

if [[ ! "${BUILD_FLAVOR}" =~ "nvidia" ]] ; then
    exit 0
fi

set -xeuo pipefail

dnf -y install gcc-c++

dnf install -y --enablerepo=terra terra-release-nvidia
dnf config-manager setopt terra-nvidia.enabled=0
dnf -y install --enablerepo=terra-nvidia akmod-nvidia
dnf -y install --enablerepo=terra-nvidia --enablerepo=terra \
    nvidia-driver-cuda libnvidia-fbc libva-nvidia-driver nvidia-driver nvidia-modprobe nvidia-persistenced nvidia-settings

dnf config-manager setopt terra-nvidia.enabled=0
sed -i '/^enabled=/a\priority=90' /etc/yum.repos.d/terra-nvidia.repo
dnf -y install --enablerepo=terra-nvidia \
    nvidia-container-toolkit

curl --retry 3 -L "https://raw.githubusercontent.com/NVIDIA/dgx-selinux/master/bin/RHEL9/nvidia-container.pp" -o nvidia-container.pp
semodule -i nvidia-container.pp
rm -f nvidia-container.pp
