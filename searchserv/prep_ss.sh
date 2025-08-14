set -xe
systemctl stop searchserv.service || true
apt install -y postgresql-common
echo | /usr/share/postgresql-common/pgdg/apt.postgresql.org.sh
apt install -y libpq5 postgresql-16-postgis-3
systemctl enable postgresql@16-main.service
systemctl start postgresql@16-main.service
apt install -y python3-venv
python3 -m venv venv
./venv/bin/pip install -r requirements.txt
sudo -u postgres dropdb postgres || true
sudo -u postgres createdb postgres
sudo -u postgres psql -f db.sql
sudo -u postgres psql -c 'vacuum full analyze;'
cp ./searchserv.service /etc/systemd/system
systemctl enable searchserv.service
systemctl start searchserv.service
