unified_mode true
provides :boxcutter_sonatype_nexus_repository

class Helpers
  extend ::Boxcutter::Sonatype::Helpers
end

action :configure do
  puts "MISCHA: list realms=#{Boxcutter::Sonatype::Helpers.get_realms_active}"
  current_realms = Boxcutter::Sonatype::Helpers.get_realms_active
  desired_realms = ['NexusAuthenticatingRealm', 'DockerToken']
  if current_realms.sort != desired_realms.sort
    Boxcutter::Sonatype::Helpers.set_realms_active(desired_realms)
  end

  # puts "MISCHA: list repositories=#{properties}"
  # node['boxcutter_sonatype']['nexus_repository']['repositories'] each do |repository_name, repository_info|
  # end

  puts "MISCHA: list repositories=#{Boxcutter::Sonatype::Helpers.repositories_list}"
  current_repository_names = Boxcutter::Sonatype::Helpers.repositories_list.map { |repo| repo['name'] }
  puts "MISCHA: current_repository_names=#{current_repository_names}"
  desired_repositories = node['boxcutter_sonatype']['nexus_repository']['repositories']
  desired_repository_names = desired_repositories.map { |key, repo| repo['name'] || key }
  puts "MISCHA: desired_repository_names=#{desired_repository_names}"
  repositories_to_delete = current_repository_names - desired_repository_names
  repositories_to_delete.each do |repository_name|
    Boxcutter::Sonatype::Helpers.repository_delete(repository_name)
  end

  node['boxcutter_sonatype']['nexus_repository']['repositories'].each do |repository_name, repository_config|
    next if current_repository_names.include?(repository_name)
    Boxcutter::Sonatype::Helpers.repository_create(repository_name, repository_config)
  end
end
