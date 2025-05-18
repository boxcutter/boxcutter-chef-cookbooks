unified_mode true
provides :boxcutter_postgresql_database

property :database_name, String, name_property: true
property :owner, [String, Integer]
property :connect_dbname, String, desired_state: false
property :connect_username, String, desired_state: false
property :connect_password, String, desired_state: false
property :connect_hostname, String, desired_state: false
property :connect_port, Integer, default: 5432, desired_state: false
property :connection_string, String, desired_state: false

load_current_value do |new_resource|
  puts 'MISCHA: boxcutter_postgresql_database: load_current_value'

  unless Boxcutter::PostgreSQL::Helpers.gem_installed?('pg')
    puts 'MISCHA pg gem is not installed yet'
    current_value_does_not_exist!
  end

  current_value_does_not_exist! unless Boxcutter::PostgreSQL::Helpers.database_exist?(new_resource)

  query_result = Boxcutter::PostgreSQL::Helpers.select_database(new_resource)
  puts "MISCHA: query_result=#{query_result}"
  database_name(query_result.fetch('datname', nil))
  owner(query_result.fetch('datdba', nil))
end

action_class do
  include Boxcutter::PostgreSQL::Helpers
end

action :create do
  puts 'MISCHA: boxcutter_postgresql_database::create'
  install_pg_gem

  unless Boxcutter::PostgreSQL::Helpers.database_exist?(new_resource)
    converge_if_changed do
      Boxcutter::PostgreSQL::Helpers.create_database(new_resource)
    end
  end
end

action :alter do
  puts 'MISCHA: boxcutter_postgresql_database::alter'
  install_pg_gem

  unless Boxcutter::PostgreSQL::Helpers.database_exist?(new_resource)
    fail Chef::Exceptions::CurrentValueDoesNotExist,
         "Cannot update database '#{new_resource.database_name}' as it does not exist"
  end

  converge_if_changed(:owner) do
    Boxcutter::PostgreSQL::Helpers.alter_database_owner(new_resource)
  end
end

action :drop do
  puts 'MISCHA: boxcutter_postgresql_role::drop'
  install_pg_gem

  if Boxcutter::PostgreSQL::Helpers.database_exist?(new_resource)
    Boxcutter::PostgreSQL::Helpers.drop_database(new_resource)
  end
end
