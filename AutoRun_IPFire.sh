#!/bin/bash

# ================================================================================================= #

echo "Downloading IPFire ISO"
linktoiso="https://downloads.ipfire.org/releases/ipfire-2.x/2.27-core171/ipfire-2.27-core171-x86_64.iso"

Caminho01="/home/administrador/ISOs"
Caminho02="/home/administrador/VMs"

echo "Criando pastas $Caminho01 e $Caminho02"
mkdir -p "$Caminho01"
mkdir -p "$Caminho02"
sleep 1

[ -f $Caminho01/ipfire.iso ] && {
  echo "IPFire.iso founded! Skipping download."
} || {
  wget $linktoiso -O $Caminho01/ipfire.iso
}

# ================================================================================================= #

echo "Creating Pools"
virsh pool-define-as Pool01 dir - - - - "$Caminho01"
virsh pool-define-as Pool02 dir - - - - "$Caminho02"
sleep 1

echo "Starting Pools"
virsh pool-start Pool01
virsh pool-start Pool02
sleep 1

echo "Setting Pools to Autostart"
virsh pool-autostart Pool01
virsh pool-autostart Pool02
sleep 1

echo "Creating Disk!"
virsh vol-create-as Pool02 IPFire.raw 25G --format raw --allocation 0
sleep 1

echo "Creating VM"
virt-install --import \
--name IPFire \
--memory 2048 \
--vcpus 2 \
--cpu host \
--network bridge=virbr0,model=e1000e \
--os-variant=linux2020 \
--graphics vnc \
--autostart

# DISK ATTACH WITH VIRSH!
