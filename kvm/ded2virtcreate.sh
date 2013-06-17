#!/bin/bash -x

DEVICE=$1
LV=$2
PORT=$3

virt-install --force -n $DEVICE -r 1536 --vcpus=1 --disk /dev/vg0/$LV,bus=scsi -c /home/username/debian-testing-amd64-netinst.iso --vnc --vnclisten=0.0.0.0  --vncport=$PORT --noautoconsole --os-type linux --os-variant debiansqueeze --accelerate --network=bridge:br0,model=virtio --hvm
