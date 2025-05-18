unified_mode true
provides :boxcutter_postgresql_access_privileges

# GRANT/REVOKE privileges ON type objects TO/FROM roles
property :privilege, String
property :type, String
property :object, String
property :role, String
property :connect_dbname, String, desired_state: false
property :connect_username, String, desired_state: false
property :connect_password, String, desired_state: false
property :connect_hostname, String, desired_state: false
property :connect_port, Integer, default: 5432, desired_state: false
property :connection_string, String, desired_state: false

# execute 'grant create on schema public to netbox' do
#   user 'postgres'
#   command %(psql -d netbox -c "GRANT CREATE ON SCHEMA public TO netbox;")
#   not_if %(psql -d netbox -tAc "SELECT has_schema_privilege('netbox', 'public', 'CREATE');" | grep -q t)
# end

action_class do
  include Boxcutter::PostgreSQL::Helpers
end

action :grant do
  puts 'MISCHA: boxcutter_postgresql_access_privileges::grant'
  install_pg_gem

  unless Boxcutter::PostgreSQL::Helpers.schema_privilege?(new_resource)
    Boxcutter::PostgreSQL::Helpers.grant_access_privileges(new_resource)
  end
end
