set -xe
apt install -y nodejs
apt install -y npm
# tileserver native dependencies
apt install -y build-essential pkg-config xvfb libglfw3-dev libuv1-dev libjpeg-turbo8 libicu70 libcairo2-dev libpango1.0-dev libjpeg-dev libgif-dev librsvg2-dev gir1.2-rsvg-2.0 librsvg2-2 librsvg2-common libcurl4-openssl-dev libpixman-1-dev libpixman-1-0

npm install -g tileserver-gl@5.2

cp tileserver.service /etc/systemd/system/
cp tileserver-xvfb.service /etc/systemd/system/
systemctl daemon-reload
systemctl enable tileserver-xvfb.service
systemctl enable tileserver.service
systemctl start tileserver-xvfb.service
systemctl start tileserver.service
