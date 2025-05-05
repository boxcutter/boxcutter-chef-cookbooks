unified_mode true
provides :boxcutter_nexus_docker_group_repository

property :repository_name, String, name_property: true
property :server_url, String
property :user_name, String
property :password, String
property :online, [TrueClass, FalseClass], default: true
property :storage_blob_store_name, String, default: 'default'
property :storage_strict_content_type_validation, [TrueClass, FalseClass], default: false
property :group_member_names, Array, default: []
property :group_writable_member
property :docker_v1_enabled, [TrueClass, FalseClass], default: false
property :docker_force_basic_auth, [TrueClass, FalseClass], default: true
property :docker_http_port, Integer
property :docker_https_port, Integer
property :docker_subdomain, String

load_current_value do |new_resource|
  response = nil
  begin
    response = Boxcutter::Sonatype::Resource::Helpers.repository_get(new_resource, 'docker', 'group')
  rescue StandardError
    current_value_does_not_exist!
  end

  if response['format'] != 'docker'
    fail 'format != docker'
  end
  if response['type'] != 'group'
    fail 'type != group'
  end
  repository_name response['name']
  online response['online']
  storage_blob_store_name response['storage']['blobStoreName']
  storage_strict_content_type_validation response['storage']['strictContentTypeValidation']
  group_member_names response['group']['memberNames']
  group_writable_member response['group']['writeableMember']
  docker_v1_enabled response['docker']['v1Enabled']
  docker_force_basic_auth response['docker']['forceBasicAuth']
  docker_http_port response['docker']['httpPort']
  docker_https_port response['docker']['httpsPort']
  docker_subdomain response['docker']['subdomain']
  puts "MISCHA: boxcutter_nexus_docker_group_repository::load_current_value #{response}"
end

action_class do
  include Boxcutter::Sonatype::Resource::Helpers
end

action :create do
  repository_exist = Boxcutter::Sonatype::Resource::Helpers.repository_exist?(new_resource, 'docker', 'group')
  puts "MISCHA boxcutter_nexus_docker_group_repository::create repository_exist=#{repository_exist}"
  unless repository_exist
    converge_if_changed do
      Boxcutter::Sonatype::Resource::Helpers.repository_create(new_resource, 'docker', 'group')
    end
  end
end

action :update do
  repository_exist = Boxcutter::Sonatype::Resource::Helpers.repository_exist?(new_resource, 'docker', 'group')
  puts "MISCHA boxcutter_nexus_docker_group_repository::update repository_exist=#{repository_exist}"
  unless repository_exist
    fail Chef::Exceptions::CurrentValueDoesNotExist,
         "Cannot update repository'#{new_resource.repository_name}' as it does not exist"
  end
  converge_if_changed(
    :online,
    :storage_blob_store_name,
    :storage_strict_content_type_validation,
    :group_member_names,
    :group_writable_member,
    :docker_v1_enabled,
    :docker_force_basic_auth,
    :docker_http_port,
    :docker_https_port,
    :docker_subdomain,
  ) do
    Boxcutter::Sonatype::Resource::Helpers.repository_update(new_resource, 'docker', 'group')
  end
end

action :delete do
  repository_exist = Boxcutter::Sonatype::Resource::Helpers.repository_exist?(new_resource, 'docker', 'group')
  puts "MISCHA boxcutter_nexus_docker_group_repository::delete repository_exist=#{repository_exist}"
  if repository_exist
    converge_by("Delete repository #{new_resource.repository_name}") do
      Boxcutter::Sonatype::Resource::Helpers.repository_delete(new_resource)
    end
  end
end
