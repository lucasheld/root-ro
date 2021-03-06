#!/bin/sh

# Error out if anything fails.
set -e

# Make sure script is run as root.
if [ "$(id -u)" != "0" ]; then
  echo "Must be run as root with sudo! Try: sudo ./install.sh"
  exit 1
fi

echo Creating initramfs...
mkinitramfs -o /boot/init.gz

if ! grep -q "^initramfs " /boot/boot.ini; then
  echo Adding \"initramfs init.gz\" to /boot/boot.ini
  echo initramfs init.gz >> /boot/boot.ini
fi

if ! grep -q "^overlay" /etc/initramfs-tools/modules; then
  echo Adding \"overlay\" to /etc/initramfs-tools/modules
  echo overlay >> /etc/initramfs-tools/modules
fi



echo Installing requirements
apt-get install dphys-swapfile -y

echo Disabling swap, we dont want swap files in a read-only root filesystem...
dphys-swapfile swapoff
dphys-swapfile uninstall
update-rc.d dphys-swapfile disable
systemctl disable dphys-swapfile

echo Setting up maintenance scripts in /root...
cp reboot-to-readonly-mode.sh /root/reboot-to-readonly-mode.sh
chmod +x /root/reboot-to-readonly-mode.sh

cp reboot-to-writable-mode.sh /root/reboot-to-writable-mode.sh
chmod +x /root/reboot-to-writable-mode.sh

echo Setting up initramfs-tools scripts...
cp etc/initramfs-tools/scripts/init-bottom/root-ro /etc/initramfs-tools/scripts/init-bottom/root-ro
chmod +x /etc/initramfs-tools/scripts/init-bottom/root-ro

cp etc/initramfs-tools/hooks/root-ro /etc/initramfs-tools/hooks/root-ro
chmod +x /etc/initramfs-tools/scripts/init-bottom/root-ro

echo Updating initramfs...
update-initramfs -u
mkinitramfs -o /boot/init.gz

if ! cat /boot/boot.ini | grep "setenv bootargs" | grep -q "root-ro-driver=overlay"; then
  echo Adding root-ro-driver parameter to /boot/boot.ini env bootargs
  sed -i 's|setenv bootargs "|setenv bootargs "root-ro-driver=overlay |' /boot/boot.ini
fi

echo Restarting Odroid
reboot
