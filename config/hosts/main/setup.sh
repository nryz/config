#! /usr/bin/env bash

set +x
set -e

user=$1
echo "user: $1"

echo "input user password"
read -s userPass

echo "input root password"
read -s rootPass
echo "choose disk"

DISK=

disks=(/dev/disk/by-id/ata-*)
select opt in "${disks[@]}"
do
        if [[ "$REPLY" == exit ]]; then exit 1; fi

        if [[ "$opt" == "" ]]
        then
                echo "'$REPLY' is not a valid number"
                continue
        fi

        DISK=$opt
        echo "using disk: $DISK"

        break
done

# Create partition table
parted $DISK -- mklabel gpt

# Create a /boot as $DISK-part1
parted $DISK -- mkpart boot fat32 1MiB 512MiB
parted $DISK -- set 1 boot on

# Create a /nix as $DISK-part2
parted $DISK -- mkpart nix 512MiB 100%

# notify partiion changes
partprobe
parted ${DISK} print

# /boot partition for EFI
mkfs.fat -F32 -v -I -n 'BOOT' -i 'B35B71DB' $DISK-part1

# /nix partition
mkfs.ext4 -F -O 64bit -L 'nix' -U '16b17eae-c8a9-48e1-bff2-466c327308b1'  $DISK-part2

# notify partition changes
partprobe
parted ${DISK} print

# Mount your root file system
mount -t tmpfs none /mnt

# Create directories
mkdir -p /mnt/{boot,nix,etc/passwords}

# notify partition changes
partprobe

# Mount /boot and /nix
mount $DISK-part1 /mnt/boot
mount $DISK-part2 /mnt/nix

mkdir -p /mnt/nix/persist/system/etc/passwords

# Bind mount the persistent configuration / logs
mount -o bind /mnt/nix/persist/system/etc/passwords /mnt/etc/passwords

mkpasswd --method=sha-512 ${userPass} | sudo tee /mnt/etc/passwords/$user 1> /dev/null
mkpasswd --method=sha-512 ${rootPass} | sudo tee /mnt/etc/passwords/root 1> /dev/null
