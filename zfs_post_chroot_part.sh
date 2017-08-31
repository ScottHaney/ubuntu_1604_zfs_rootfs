# Now for non-chroot work...
sudo umount /mnt/local_desktop
sudo rm -r /mnt/local_desktop

sudo mount | grep -v zfs | tac | awk '/\/mnt/ {print $3}' | xargs -i{} sudo umount -lf {}
sudo zpool export rpool
