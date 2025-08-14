set -xe
apt-get install -y nginx
# config file is edited by mkstick

cp nginx.conf /etc/nginx/
systemctl enable nginx.service
systemctl start nginx.service
