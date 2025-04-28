unified_mode true
provides :boxcutter_postgresql_role

property :role_name, String, name_property: true
property :plain_text_password, String
property :encrypted_password, String

load_current_value do |new_resource|
  puts 'MISCHA: boxcutter_postgresql_role: load_current_value'

  unless Boxcutter::PostgreSQL::Helpers.gem_installed?('pg')
    puts 'MISCHA pg gem is not installed yet'
  end

  current_value_does_not_exist! unless Boxcutter::PostgreSQL::Helpers.role_exist?(new_resource.role_name)

  query_result = Boxcutter::PostgreSQL::Helpers.select_role(new_resource.role_name)
  puts "MISCHA: query_result=#{query_result}"
  role_name(query_result.fetch('rolname', nil))
end

action_class do
  include Boxcutter::PostgreSQL::Helpers
end

action :create do
  puts 'MISCHA: boxcutter_postgresql_role::create'
  install_pg_gem

  return if Boxcutter::PostgreSQL::Helpers.role_exist?(new_resource.role_name)

  converge_if_changed(:plain_text_password, :encrypted_password) do
    Boxcutter::PostgreSQL::Helpers.create_role(new_resource)
  end
end

action :alter do
end

action :drop do
end
