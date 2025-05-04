unified_mode true
provides :boxcutter_nexus_apt_hosted_repository

property :repository_name, String, name_property: true
property :server_url, String
property :user_name, String
property :password, String
property :online, [TrueClass, FalseClass], default: true
property :storage_blob_store_name, String, default: 'default'
property :storage_strict_content_type_validation, [TrueClass, FalseClass], default: false
property :storage_write_policy, String,
         equal_to: %w[allow allow_once read_only],
         default: 'allow'
# property :cleanup_policy_names
# property :component_proprietary_components
property :apt_distribution, String, default: 'bionic'
property :apt_signing_keypair, String
property :apt_signing_passphrase, String

load_current_value do |new_resource|
  response = nil
  begin
    response = Boxcutter::Sonatype::Resource::Helpers.repository_get(new_resource, 'apt', 'hosted')
  rescue
    current_value_does_not_exist!
  end

  if response['format'] != 'apt'
    raise 'format != apt'
  end
  if response['type'] != 'hosted'
    raise 'type != hosted'
  end
  repository_name response['name']
  online response['online']
  storage_blob_store_name response['storage']['blobStoreName']
  storage_strict_content_type_validation response['storage']['strictContentTypeValidation']
  storage_write_policy response['storage']['writePolicy']
  apt_distribution response['apt']['distribution']
  apt_signing_keypair response['aptSigning']['keypair']
  apt_signing_passphrase response['aptSigning']['passphrase']
  puts "MISCHA: boxcutter_nexus_apt_hosted_repository::load_current_value #{response}"
end

action_class do
  include Boxcutter::Sonatype::Resource::Helpers
end

action :create do
  repository_exist = Boxcutter::Sonatype::Resource::Helpers.repository_exist?(new_resource, 'apt', 'hosted')
  puts "MISCHA boxcutter_nexus_apt_hosted_repository::create repository_exist=#{repository_exist}"
  unless repository_exist
    converge_if_changed do
      Boxcutter::Sonatype::Resource::Helpers.repository_create(new_resource, 'apt', 'hosted')
    end
  end
end

action :update do
  repository_exist = Boxcutter::Sonatype::Resource::Helpers.repository_exist?(new_resource, 'apt', 'hosted')
  puts "MISCHA boxcutter_nexus_apt_hosted_repository::update repository_exist=#{repository_exist}"
  unless repository_exist
    raise Chef::Exceptions::CurrentValueDoesNotExist, "Cannot update repository'#{new_resource.repository_name}' as it does not exist"
  end
  converge_if_changed(
    :online,
    :storage_blob_store_name,
    :storage_strict_content_type_validation,
    :storage_write_policy,
    :apt_distribution,
    :apt_signing_keypair,
    :apt_signing_passphrase,
  ) do
    Boxcutter::Sonatype::Resource::Helpers.repository_update(new_resource, 'apt', 'hosted')
  end
end

action :delete do
  repository_exist = Boxcutter::Sonatype::Resource::Helpers.repository_exist?(new_resource, 'apt', 'hosted')
  puts "MISCHA boxcutter_nexus_apt_hosted_repository::delete repository_exist=#{repository_exist}"
  if repository_exist
    converge_by("Delete repository #{new_resource.repository_name}") do
      Boxcutter::Sonatype::Resource::Helpers.repository_delete(new_resource)
    end
  end
end