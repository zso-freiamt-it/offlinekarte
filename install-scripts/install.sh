set -xe
apt update
mkdir /home/zso/zsk/
rsync -Rr --progress release /home/zso/zsk/
cd /home/zso/zsk/release/
sh prep.sh
mkdir /mnt/c/ZSKarte
cd /home/zso/usb/
cp zskarte.bat /mnt/c/ZSKarte/
cp ZSIcon.ico /mnt/c/ZSKarte/
cp launch-wsl.vbs /mnt/c/ZSKarte/
