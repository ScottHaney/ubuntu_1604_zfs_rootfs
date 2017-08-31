sudo apt-add-repository universe
sudo apt update

sudo apt install --yes debootstrap gdisk zfs-initramfs

readonly DISK=/dev/disk/by-id/ata-LITEON_IT_LDS-256L9S_SD0G54239L1TH56101F9

sudo sgdisk --zap-all $DISK
sudo dd if=/dev/zero of=$DISK bs=1M count=2000
sudo sgdisk -n3:1M:+512M -t3:EF00 $DISK
sudo sgdisk -n9:-8M:0 -t9:BF07 $DISK

sudo sgdisk -n4:0:+512M -t4:8300 $DISK
sudo sgdisk -n1:0:0 -t1:8300 $DISK

sudo partprobe

sudo cryptsetup luksFormat -c aes-xts-plain64 -s 256 -h sha256 $DISK-part1
sudo cryptsetup luksOpen $DISK-part1 luks1

sudo zpool create -o ashift=12 \
      -O atime=off -O canmount=off -O compression=lz4 -O normalization=formD \
      -O mountpoint=/ -R /mnt \
      rpool /dev/mapper/luks1

sudo zfs create -o canmount=off -o mountpoint=none rpool/ROOT
sudo zfs create -o canmount=noauto -o mountpoint=/ rpool/ROOT/ubuntu
sudo zfs mount rpool/ROOT/ubuntu

sudo zfs create -o setuid=off                              rpool/home
sudo zfs create -o mountpoint=/root                        rpool/home/root
sudo zfs create -o canmount=off -o setuid=off  -o exec=off rpool/var
sudo zfs create -o com.sun:auto-snapshot=false             rpool/var/cache
sudo zfs create                                            rpool/var/log
sudo zfs create                                            rpool/var/spool
sudo zfs create -o com.sun:auto-snapshot=false -o exec=on  rpool/var/tmp

sudo mke2fs -t ext2 $DISK-part4
sudo mkdir /mnt/boot
sudo mount $DISK-part4 /mnt/boot

sudo chmod 1777 /mnt/var/tmp
sudo debootstrap --variant=buildd xenial /mnt http://archive.ubuntu.com/ubuntu/
sudo zfs set devices=off rpool

sudo /bin/bash -c "cat > /mnt/etc/apt/sources.list" << EOF
deb http://archive.ubuntu.com/ubuntu xenial main universe
deb-src http://archive.ubuntu.com/ubuntu xenial main universe

deb http://security.ubuntu.com/ubuntu xenial-security main universe
deb-src http://security.ubuntu.com/ubuntu xenial-security main universe

deb http://archive.ubuntu.com/ubuntu xenial-updates main universe
deb-src http://archive.ubuntu.com/ubuntu xenial-updates main universe
EOF

sudo mount --rbind /dev  /mnt/dev
sudo mount --rbind /proc /mnt/proc
sudo mount --rbind /sys  /mnt/sys

sudo mkdir /mnt/local_desktop
sudo mount --bind /home/ubuntu/Desktop /mnt/local_desktop
