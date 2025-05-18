# boxcutter_netbox

```
# https://netboxlabs.com/docs/netbox/en/stable/installation/1-postgresql/
# Configure PostgreSQL 16 - create database
su - postgres -s /bin/bash <<'EOF'
psql <<SQL
CREATE DATABASE netbox;
CREATE USER netbox WITH PASSWORD 'superseekret';
ALTER DATABASE netbox OWNER TO netbox;
SQL

psql -d netbox <<SQL
GRANT CREATE ON SCHEMA public TO netbox;
SQL
EOF


su - postgres
psql
CREATE DATABASE netbox;
CREATE USER netbox WITH PASSWORD 'superseekret';
ALTER DATABASE netbox OWNER TO netbox;
-- the next two commands are needed on PostgreSQL 15 and later
\connect netbox;
GRANT CREATE ON SCHEMA public TO netbox;
\q
exit


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
