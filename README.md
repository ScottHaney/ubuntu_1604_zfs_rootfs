# ubuntu_1604_zfs_rootfs
Install scripts used to install Ubuntu 16.04 with a rootfs of ZFS and luks encryption. These scripts were written from following the instructions at the [zfsonline wiki](https://github.com/zfsonlinux/zfs/wiki/Ubuntu-16.04-Root-on-ZFS).

The scripts are in rough condition currently as they are just what I put together to get the install working, I may clean them up later. Also my install was marred by issues with my broadcom wireless driver, I did some extra steps to make sure that I could complete the install without requiring an ethernet connection for convenience. To install I did the following (please note the restrictions at the top of the zfsonline wiki link mentioned in the previous paragraph in case your system won't work with a zfs rootfs):

1. Create an Ubuntu 16.04 live media device (I used a usb).
2. (Possibly optional) Run yoga_internet_setup.sh to get your wireless card to be recognized. This can be tricky, but for my lenovo yoga the script I have worked. For a different machine it might not, but the instructions given in the [answer to this ask ubuntu question](https://askubuntu.com/questions/55868/installing-broadcom-wireless-drivers) may show you what modifications are needed to get it working for your machine.
3. Now that wifi networks can be recognized connect to one of them
4. Run zfs_install.sh and enter passwords as required (this script sets up luks encryption on the drive)
5. Run "chroot /mnt /bin/bash --login"
6. The zfs_install.sh script from step 4 mapped the /home/ubuntu/Desktop directory into the /mtn/local_desktop directory of the chroot. The zfs_chroot_part.sh script should be placed in /home/ubuntu/Desktop so that it can be accessible from the /mnt/local_desktop/zfs_chroot_part.sh path in the chroot. Run /mnt/local_desktop/zfs_chroot_part.sh.
7. Exit the chroot using the "exit" command. After you have exited the chroot run zfs_post_chroot_part.sh.
8. Reboot the machine into the new install
9. The new install should only have a guest account, login to it. After logging in open a terminal using Ctrl+Alt+T. In the terminal run the lines from zfs_after_install.sh manually making sure to change the user name to what you would like it to be.
10. You should now have the complete system together!
