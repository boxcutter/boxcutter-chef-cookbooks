unified_mode true
provides :boxcutter_sonatype_nexus_repository

class Helpers
  extend ::Boxcutter::Sonatype::Helpers
end

action :configure do
  puts "MISCHA: list realms=#{Boxcutter::Sonatype::Helpers.get_realms_active(node)}"
  current_realms = Boxcutter::Sonatype::Helpers.get_realms_active(node)
  desired_realms = ['NexusAuthenticatingRealm', 'DockerToken']
  if current_realms.sort != desired_realms.sort
    Boxcutter::Sonatype::Helpers.set_realms_active(node, desired_realms)
  end

  # puts "MISCHA: list repositories=#{properties}"
  # node['boxcutter_sonatype']['nexus_repository']['repositories'] each do |repository_name, repository_info|
  # end

  puts "MISCHA: list blobstores=#{Boxcutter::Sonatype::Helpers.blobstores_list(node)}"
  current_blobstore_names = Boxcutter::SonaType::Helpers.blobstores_list(node).map { |blobstore| blobstore['name'] }
  puts "MISCHA: current_blobstore_names=#{current_blobstore_names}"
  desired_blobstores = node['boxcutter_sonatype']['nexus_repository']['blobstores']
  desired_blobstore_names = desired_blobstores.map { |key, blobstore| blobstore['name'] || key }
  puts "MISCHA: desired_blobstore_names=#{desired_blobstore_names}"
  blobstores_to_delete = current_blobstore_names - desired_blobstore_names
  blobstores_to_delete.each do |blobstore_name|
    Boxcutter::Sonatype::Helpers.blobstore_delete(node, blobstore_name)
  end

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

  node['boxcutter_sonatype']['nexus_repository']['blobstores'].each do |blobstore_name, blobstore_config|
    next if current_blobstore_names.include?(blobstore_name)
    Boxcutter::Sonatype::Helpers.blobstore_create(node, blobstore_name, blobstore_config)
  end

  node['boxcutter_sonatype']['nexus_repository']['repositories'].each do |repository_name, repository_config|
    next if current_repository_names.include?(repository_name)
    Boxcutter::Sonatype::Helpers.repository_create(node, repository_name, repository_config)
  end
end
