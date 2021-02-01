#!/bin/sh

# partition size in MB
BOOT_ROM_SIZE=10

# wait for the SD/MMC device node ready
while [ ! -e $1 ]
do
sleep 1
echo “wait for $1 appear”
done

parted -l
# call sfdisk to create partition table
# destroy the partition table
node=$1

sfdisk --force ${node} << EOF
${BOOT_ROM_SIZE}M,500M,0c
600M,,83
EOF
