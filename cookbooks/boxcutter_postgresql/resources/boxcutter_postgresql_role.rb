unified_mode true
provides :boxcutter_postgresql_role

property :role_name, String, name_property: true
property :plain_text_password, String
property :encrypted_password, String
property :connect_dbname, String, desired_state: false
property :connect_username, String, desired_state: false
property :connect_password, String, desired_state: false
property :connect_hostname, String, desired_state: false
property :connect_port, Integer, default: 5432, desired_state: false
property :connection_string, String, desired_state: false

load_current_value do |new_resource|
  puts 'MISCHA: boxcutter_postgresql_role: load_current_value'

  unless Boxcutter::PostgreSQL::Helpers.gem_installed?('pg')
    puts 'MISCHA pg gem is not installed yet'
    current_value_does_not_exist!
  end

  current_value_does_not_exist! unless Boxcutter::PostgreSQL::Helpers.role_exist?(new_resource)

  query_result = Boxcutter::PostgreSQL::Helpers.select_role(new_resource)
  puts "MISCHA: query_result=#{query_result}"
  role_name(query_result.fetch('rolname', nil))
end

action_class do
  include Boxcutter::PostgreSQL::Helpers
end

action :create do
  puts 'MISCHA: boxcutter_postgresql_role::create'
  install_pg_gem

  return if Boxcutter::PostgreSQL::Helpers.role_exist?(new_resource)

  converge_if_changed(:plain_text_password, :encrypted_password) do
    Boxcutter::PostgreSQL::Helpers.create_role(new_resource)
  end

  converge_if_changed(:plain_text_password, :encrypted_password) do
    Boxcutter::PostgreSQL::Helpers.alter_role_password(new_resource)
  end
end

action :alter do
  puts 'MISCHA: boxcutter_postgresql_role::alter'
  install_pg_gem

  unless Boxcutter::PostgreSQL::Helpers.role_exist?(new_resource)
    fail Chef::Exceptions::CurrentValueDoesNotExist,
         "Cannot update role '#{new_resource.rele_name}' as it does not exist"
  end

  converge_if_changed(:plain_text_password, :encrypted_password) do
    Boxcutter::PostgreSQL::Helpers.alter_role_password(new_resource)
  end
end

action :drop do
  puts 'MISCHA: boxcutter_postgresql_role::drop'
  install_pg_gem

  if Boxcutter::PostgreSQL::Helpers.role_exist?(new_resource)
    Boxcutter::PostgreSQL::Helpers.drop_role(new_resource)
  end
end
