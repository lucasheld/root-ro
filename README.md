# Read-only root filesystem for Odroid C1 running Debian Stretch

## Setup
```
sudo apt-get -y install git
cd /home/pi
git clone https://github.com/lucasheld/root-ro.git
cd root-ro
chmod +x install.sh
sudo ./install.sh
```
The install.sh script will configure and immediately reboot the system into readonly mode.

## Rebooting to permanent write-mode (disabling the overlay fs)
```
sudo /root/reboot-to-writable-mode.sh
```

## Rebooting to permanent read-only mode (enabling the overlay fs)
```
sudo /root/reboot-to-readonly-mode.sh
```

## Enabling temporary write access mode:
```
sudo mount -o remount,rw /mnt/root-ro
# next command enables DNS in chroot because resolvconf service needs to read /run/resolvconf/resolv.conf
sudo mount -o bind /run /mnt/root-ro/run
chroot /mnt/root-ro
```

## Exiting temporary write access mode:
```
exit
sudo mount -o remount,ro /mnt/root-ro
```
