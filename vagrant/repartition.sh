#!/usr/bin/env bash
set -exuv -o pipefail

# expected /dev/sda structure
# Device     Boot Start      End  Sectors Size Id Type
# /dev/sda1  *     2048 20971486 20969439  10G 83 Linux

sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' <<EOF | fdisk /dev/sda
    d #
    n # new
    p # primary
    1 #
      # default - start at beginning of disk
      # default, extend partition to end of disk
    N # Partition 1 contains a ext4 signature. Do you want to remove the signature? [Y]es/[N]o:
    a # make a partition bootable
    p # print the in-memory partition table
    w # write the partition table
EOF

# 120Gb
resize2fs /dev/sda1 31457024
sync