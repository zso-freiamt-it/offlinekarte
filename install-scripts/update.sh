set -xe
apt update
rm -rf /home/zso/zsk/
mkdir /home/zso/zsk/
rsync -Rr --progress release /home/zso/zsk/
cd /home/zso/zsk/release/
sh prep.sh
