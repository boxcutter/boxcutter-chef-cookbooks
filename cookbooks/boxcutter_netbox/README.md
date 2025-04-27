# boxcutter_netbox

```bash
# https://netboxlabs.com/docs/netbox/en/stable/installation/1-postgresql/
# Configure PostgreSQL 16 - create database
su - postgres
psql
CREATE DATABASE netbox;
CREATE USER netbox WITH PASSWORD 'J5brHrAXFLQSif0K';
ALTER DATABASE netbox OWNER TO netbox;
-- the next two commands are needed on PostgreSQL 15 and later
\connect netbox;
GRANT CREATE ON SCHEMA public TO netbox;
\q
exit

# https://netboxlabs.com/docs/netbox/en/stable/installation/3-netbox/
su -
cp \
  /opt/netbox/latest/netbox/netbox/configuration_example.py \
  /opt/netbox/latest/netbox/netbox/configuration.py

python3 /opt/netbox/latest/netbox/generate_secret_key.py
B@Li4HVu1^E4$5#2)Ulr$dlWMM2z4p2s*XRayfkaKe9h^gwM)B

vi /opt/netbox/latest/netbox/netbox/configuration.py
ALLOWED_HOSTS = ['*']

DATABASE = {
    'NAME': 'netbox',               # Database name
    'USER': 'netbox',               # PostgreSQL username
    'PASSWORD': 'J5brHrAXFLQSif0K', # PostgreSQL password
    'HOST': 'localhost',            # Database server
    'PORT': '',                     # Database port (leave blank for default)
    'CONN_MAX_AGE': 300,            # Max database connection age (seconds)
}

SECRET_KEY = 'B@Li4HVu1^E4$5#2)Ulr$dlWMM2z4p2s*XRayfkaKe9h^gwM)B'


# upgrade
/opt/netbox/latest/upgrade.sh

# Create a super user
source /opt/netbox/latest/venv/bin/activate
cd /opt/netbox/latest/netbox
python3 manage.py createsuperuser
# python3 manage.py createsuperuser
Username: admin
Email address: admin@example.com
Password: 
Password (again): 
Superuser created successfully.

python3 manage.py runserver 0.0.0.0:8000 --insecure

http://localhost:2404
```

```
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/ssl/private/netbox.key \
  -out /etc/ssl/certs/netbox.crt

sudo apt install -y nginx

sudo cp /opt/netbox/contrib/nginx.conf /etc/nginx/sites-available/netbox

sudo rm /etc/nginx/sites-enabled/default
sudo ln -s /etc/nginx/sites-available/netbox /etc/nginx/sites-enabled/netbox

sudo systemctl restart nginx

```
