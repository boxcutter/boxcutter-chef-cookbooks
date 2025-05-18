#
# Cookbook:: boxcutter_postgresql_test
# Recipe:: server
#

include_recipe 'boxcutter_postgresql::server'

# https://www.red-gate.com/simple-talk/databases/postgresql/postgresql-basics-roles-and-privileges/
boxcutter_postgresql_role 'dev1' do
  # plain_text_password 'superseekret'
  # action :alter
end

boxcutter_postgresql_database 'test1' do

end

boxcutter_postgresql_role 'netbox'

boxcutter_postgresql_database 'netbox'

boxcutter_postgresql_access_privileges 'GRANT CREATE ON SCHEMA public TO netbox' do
  privilege 'CREATE'
  type 'SCHEMA'
  object 'public'
  role 'netbox'
  connect_dbname 'netbox'
end

# su - postgres
# pg_lsclusters
# psql
# SELECT rolname FROM pg_roles WHERE rolname='dev1';