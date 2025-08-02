boxcutter_netbox
==================

```
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
