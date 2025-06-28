unified_mode true
provides :boxcutter_postgresql

action_class do
  include Boxcutter::PostgreSQL::Helpers
end

action :configure do
  puts "MISCHA: list_roles=#{Boxcutter::PostgreSQL::Helpers.list_roles(node)}"
  # puts "MISCHA: list repositories=#{Boxcutter::Sonatype::Helpers.repositories_list(node)}"
  # current_repository_names = Boxcutter::Sonatype::Helpers.repositories_list(node).map { |repo| repo['name'] }
  # puts "MISCHA: current_repository_names=#{current_repository_names}"

  # desired_roles = node['boxcutter_postgresql']['server']['roles']
  # desired_role_names = desired_roles.map { |key, role| role['role_name'] || key }
  # puts "MISCHA: desired_role_names=#{desired_role_names}"
  #
  # node['boxcutter_postgresql']['server']['roles'].each do |key, role_config|
  #   role_name = role_config['role_name'] || key
  #
  #   boxcutter_postgresql_role role_name do
  #   end
  # end
end
