# sudo chroot /mnt /bin/bash --login
readonly DISK=/dev/disk/by-id/ata-LITEON_IT_LDS-256L9S_SD0G54239L1TH56101F9

locale-gen en_US.UTF-8
echo LANG=en_US.UTF-8 > /etc/default/locale

dpkg-reconfigure tzdata

ln -s /proc/self/mounts /etc/mtab
apt update
apt install --yes ubuntu-minimal

apt install --yes --no-install-recommends linux-image-generic
apt install --yes zfs-initramfs
apt install --yes linux-headers-generic
apt install --yes dkms

apt dist-upgrade --yes
apt install --yes ubuntu-desktop

echo UUID=$(blkid -s UUID -o value \
      $DISK-part4) \
      /boot ext2 defaults 0 2 >> /etc/fstab

apt install --yes cryptsetup

echo luks1 UUID=$(blkid -s UUID -o value \
      $DISK-part1) none \
      luks,discard,initramfs > /etc/crypttab

cat > /etc/udev/rules.d/99-local-crypt.rules << EOF
ENV{DM_NAME}!="", SYMLINK+="$env{DM_NAME}"
ENV{DM_NAME}!="", SYMLINK+="dm-name-$env{DM_NAME}"
EOF

ln -s /dev/mapper/luks1 /dev/luks1

# Install GRUB
apt install --yes grub-pc
apt install --yes dosfstools
mkdosfs -F 32 -n EFI $DISK-part3

mkdir /boot/efi

echo PARTUUID=$(blkid -s PARTUUID -o value \
      $DISK-part3) \
      /boot/efi vfat nofail,x-systemd.device-timeout=1 0 1 >> /etc/fstab

mount /boot/efi
apt install --yes grub-efi-amd64

addgroup --system lpadmin
passwd

zfs set mountpoint=legacy rpool/var/log
zfs set mountpoint=legacy rpool/var/tmp
cat >> /etc/fstab << EOF
rpool/var/log /var/log zfs defaults 0 0
rpool/var/tmp /var/tmp zfs defaults 0 0
EOF

update-initramfs -c -k all
update-grub
grub-install --target=x86_64-efi --efi-directory=/boot/efi \
      --bootloader-id=ubuntu --recheck --no-floppy

zfs snapshot rpool/ROOT/ubuntu@install
