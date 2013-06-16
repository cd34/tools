#!/bin/bash -x

DEVICE=$0
LV=$1
PORT=$2

virt-install --force --import -n $DEVICE -r 1536 --vcpus=1 --disk /dev/vg0/$LV,bus=scsi --vnc --vnclisten=0.0.0.0  --vncport=$PORT --noautoconsole --os-type linux --os-variant debiansqueeze --accelerate --network=bridge:br0,model=virtio --hvm
