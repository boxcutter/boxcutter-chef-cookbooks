unified_mode true
provides :boxcutter_sonatype_nexus_repository

action_class do
  include Boxcutter::Sonatype::Helpers
end

action :configure do
  puts "MISCHA: list realms=#{Boxcutter::Sonatype::Helpers.get_realms_active(node)}"
  current_realms = Boxcutter::Sonatype::Helpers.get_realms_active(node)
  desired_realms = ['NexusAuthenticatingRealm', 'DockerToken']
  if current_realms.sort != desired_realms.sort
    Boxcutter::Sonatype::Helpers.set_realms_active(node, desired_realms)
  end

  puts "MISCHA: list roles=#{Boxcutter::Sonatype::Helpers.roles_list(node)}"
  current_role_names = Boxcutter::Sonatype::Helpers.roles_list(node).map { |role| role['id'] }
  puts "MISCHA: current_role_names=#{current_role_names}"
  filtered_current_role_names = current_role_names.reject do |user_id|
    ['nx-admin', 'nx-anonymous'].include?(user_id)
  end
  puts "MISCHA: filtered_current_user_names=#{filtered_current_role_names}"
  desired_roles = node['boxcutter_sonatype']['nexus_repository']['roles']
  desired_role_names = desired_roles.map { |key, role| role['id'] || key }
  puts "MISCHA: desired_role_names=#{desired_role_names}"
  roles_to_delete = filtered_current_role_names - desired_role_names
  roles_to_delete.each do |role_name|
    Boxcutter::Sonatype::Helpers.role_delete(node, role_name)
  end

  puts "MISCHA: list users=#{Boxcutter::Sonatype::Helpers.users_list(node)}"
  current_user_names = Boxcutter::Sonatype::Helpers.users_list(node).map { |user| user['userId'] }
  puts "MISCHA: current_user_names=#{current_user_names}"
  filtered_current_user_names = current_user_names.reject do |user_id|
    ['anonymous', 'admin'].include?(user_id)
  end
  puts "MISCHA: filtered_current_user_names=#{filtered_current_user_names}"
  desired_users = node['boxcutter_sonatype']['nexus_repository']['users']
  desired_user_names = desired_users.map { |key, user| user['user_id'] || key }
  puts "MISCHA: desired_user_names=#{desired_user_names}"
  users_to_delete = filtered_current_user_names - desired_user_names
  users_to_delete.each do |user_name|
    Boxcutter::Sonatype::Helpers.user_delete(node, user_name)
  end

  puts "MISCHA: list blobstores=#{Boxcutter::Sonatype::Helpers.blobstores_list(node)}"
  current_blobstore_names = Boxcutter::Sonatype::Helpers.blobstores_list(node).map { |blobstore| blobstore['name'] }
  puts "MISCHA: current_blobstore_names=#{current_blobstore_names}"
  desired_blobstores = node['boxcutter_sonatype']['nexus_repository']['blobstores']
  desired_blobstore_names = desired_blobstores.map { |key, blobstore| blobstore['name'] || key }
  puts "MISCHA: desired_blobstore_names=#{desired_blobstore_names}"
  blobstores_to_delete = current_blobstore_names - desired_blobstore_names
  blobstores_to_delete.each do |blobstore_name|
    Boxcutter::Sonatype::Helpers.blobstore_delete(node, blobstore_name)
  end

  # puts "MISCHA: list repositories=#{properties}"
  # node['boxcutter_sonatype']['nexus_repository']['repositories'] each do |repository_name, repository_info|
  # end

  puts "MISCHA: list repositories=#{Boxcutter::Sonatype::Helpers.repositories_list(node)}"
  current_repository_names = Boxcutter::Sonatype::Helpers.repositories_list(node).map { |repo| repo['name'] }
  puts "MISCHA: current_repository_names=#{current_repository_names}"
  desired_repositories = node['boxcutter_sonatype']['nexus_repository']['repositories']
  desired_repository_names = desired_repositories.map { |key, repo| repo['name'] || key }
  puts "MISCHA: desired_repository_names=#{desired_repository_names}"
  repositories_to_delete = current_repository_names - desired_repository_names
  repositories_to_delete.each do |repository_name|
    Boxcutter::Sonatype::Helpers.repository_delete(node, repository_name)
  end

  node['boxcutter_sonatype']['nexus_repository']['roles'].each do |key, role_config|
    role_id = role_config['id'] || key
    next if filtered_current_role_names.include?(role_id)
    Boxcutter::Sonatype::Helpers.role_create(node, role_id, role_config)
  end

  node['boxcutter_sonatype']['nexus_repository']['users'].each do |key, user_config|
    user_name = user_config['name'] || key
    next if filtered_current_user_names.include?(user_name)
    Boxcutter::Sonatype::Helpers.user_create(node, user_name, user_config)
  end

  node['boxcutter_sonatype']['nexus_repository']['blobstores'].each do |key, blobstore_config|
    blobstore_name = blobstore_config['name'] || key
    next if current_blobstore_names.include?(blobstore_name)
    Boxcutter::Sonatype::Helpers.blobstore_create(node, blobstore_name, blobstore_config)
  end

  node['boxcutter_sonatype']['nexus_repository']['repositories'].each do |key, repository_config|
    repository_name = repository_config['name'] || key
    if current_repository_names.include?(repository_name)
      repository_update(node, repository_name, repository_config)
    else
      repository_create(node, repository_name, repository_config)
    end
  end
end
