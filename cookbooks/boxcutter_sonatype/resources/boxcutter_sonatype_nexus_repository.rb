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

  node['boxcutter_sonatype']['nexus_repository']['roles'].each do |role_id, role_config|
    next if filtered_current_role_names.include?(role_id)
    Boxcutter::Sonatype::Helpers.role_create(node, role_id, role_config)
  end

  node['boxcutter_sonatype']['nexus_repository']['users'].each do |user_name, user_config|
    next if filtered_current_user_names.include?(user_name)
    Boxcutter::Sonatype::Helpers.user_create(node, user_name, user_config)
  end

  node['boxcutter_sonatype']['nexus_repository']['blobstores'].each do |blobstore_name, blobstore_config|
    next if current_blobstore_names.include?(blobstore_name)
    Boxcutter::Sonatype::Helpers.blobstore_create(node, blobstore_name, blobstore_config)
  end

  node['boxcutter_sonatype']['nexus_repository']['repositories'].each do |repository_name, repository_config|
    # next if current_repository_names.include?(repository_name)
    # Boxcutter::Sonatype::Helpers.repository_create(node, repository_name, repository_config)

    repository_format = repository_config['format']
    repository_type = repository_config['type']
    server_url = 'http://localhost:8081'
    user_name = Boxcutter::Sonatype::Helpers.admin_username(node)
    password = Boxcutter::Sonatype::Helpers.admin_password(node)

    action = :create
    action = :update if current_repository_names.include?(repository_name)
    case repository_format
    when 'apt'
      case repository_type
      when 'hosted'
        boxcutter_nexus_apt_hosted_repository repository_name do
          server_url server_url
          user_name user_name
          password password
          online repository_config['online']
          storage_blob_store_name repository_config['storage_blob_store_name']
          storage_strict_content_type_validation repository_config['storage_strict_content_type_validation']
          storage_write_policy repository_config['storage_write_policy']
          apt_distribution repository_config['apt_distribution']
          apt_signing_keypair repository_config['apt_signing_keypair']
          apt_signing_passphrase repository_config['apt_signing_passphrase']

          action action
        end
      when 'proxy'
        boxcutter_nexus_apt_proxy_repository repository_name do
          server_url server_url
          user_name user_name
          password password
          online repository_config['online']
          storage_blob_store_name repository_config['storage_blob_store_name']
          storage_strict_content_type_validation repository_config['storage_strict_content_type_validation']
          proxy_remote_url repository_config['proxy_remote_url']
          proxy_content_max_age repository_config['proxy_content_max_age']
          proxy_metadata_max_age repository_config['proxy_metadata_max_age']
          negative_cache_enabled repository_config['negative_cache_enabled']
          negative_cache_time_to_live repository_config['negative_cache_time_to_live']
          http_client_blocked repository_config['http_client_blocked']
          http_client_auto_block repository_config['http_client_auto_block']
          http_client_connection_retries repository_config['http_client_connection_retries']
          http_client_connection_user_agent_suffix repository_config['http_client_connection_user_agent_suffix']
          http_client_connection_timeout repository_config['http_client_connection_timeout']
          http_client_connection_enable_circular_redirects \
            repository_config['http_client_connection_enable_circular_redirects']
          http_client_connection_enable_cookies repository_config['http_client_connection_enable_cookies']
          http_client_connection_use_trust_store repository_config['http_client_connection_use_trust_store']
          http_client_authentication_type repository_config['http_client_authentication_type']
          http_client_authentication_username repository_config['http_client_authentication_username']
          http_client_authentication_password repository_config['http_client_authentication_password']
          http_client_authentication_ntlm_host repository_config['http_client_authentication_ntlm_host']
          http_client_authentication_ntlm_domain repository_config['http_client_authentication_ntlm_domain']
          routing_rule repository_config['routing_rule']
          apt_distribution repository_config['apt_distribution']
          apt_flat repository_config['apt_flat']

          action action
        end
      else
        fail "invalid type #{type}"
      end
    when 'docker'
      case repository_type
      when 'group'
        boxcutter_nexus_docker_group_repository repository_name do
          server_url server_url
          user_name user_name
          password password
          online repository_config['online']
          storage_blob_store_name repository_config['storage_blob_store_name']
          storage_strict_content_type_validation repository_config['storage_strict_content_type_validation']
          group_member_names repository_config['group_member_names']
          group_writable_member repository_config['group_writable_member']
          docker_v1_enabled repository_config['docker_v1_enabled']
          docker_force_basic_auth repository_config['docker_force_basic_auth']
          docker_http_port repository_config['docker_http_port']
          docker_https_port repository_config['docker_https_port']
          docker_subdomain repository_config['docker_subdomain']

          action action
        end
      when 'hosted'
        boxcutter_nexus_docker_hosted_repository repository_name do
          server_url server_url
          user_name user_name
          password password
          online repository_config['online']
          storage_blob_store_name repository_config['storage_blob_store_name']
          storage_strict_content_type_validation repository_config['storage_strict_content_type_validation']
          storage_write_policy repository_config['storage_write_policy']
          storage_latest_policy repository_config['storage_latest_policy']
          docker_v1_enabled repository_config['docker_v1_enabled']
          docker_force_basic_auth repository_config['docker_force_basic_auth']
          docker_http_port repository_config['docker_http_port']
          docker_https_port repository_config['docker_https_port']
          docker_subdomain repository_config['docker_subdomain']

          action action
        end
      when 'proxy'
        boxcutter_nexus_docker_proxy_repository repository_name do
          server_url server_url
          user_name user_name
          password password
          online repository_config['online']
          storage_blob_store_name repository_config['storage_blob_store_name']
          storage_strict_content_type_validation repository_config['storage_strict_content_type_validation']
          proxy_remote_url repository_config['proxy_remote_url']
          proxy_content_max_age repository_config['proxy_content_max_age']
          proxy_metadata_max_age repository_config['proxy_metadata_max_age']
          negative_cache_enabled repository_config['negative_cache_enabled']
          negative_cache_time_to_live repository_config['negative_cache_time_to_live']
          http_client_blocked repository_config['http_client_blocked']
          http_client_auto_block repository_config['http_client_auto_block']
          http_client_connection_retries repository_config['http_client_connection_retries']
          http_client_connection_user_agent_suffix repository_config['http_client_connection_user_agent_suffix']
          http_client_connection_timeout repository_config['http_client_connection_timeout']
          http_client_connection_enable_circular_redirects \
            repository_config['http_client_connection_enable_circular_redirects']
          http_client_connection_enable_cookies repository_config['http_client_connection_enable_cookies']
          http_client_connection_use_trust_store repository_config['http_client_connection_use_trust_store']
          http_client_authentication_type repository_config['http_client_authentication_type']
          http_client_authentication_username repository_config['http_client_authentication_username']
          http_client_authentication_password repository_config['http_client_authentication_password']
          http_client_authentication_ntlm_host repository_config['http_client_authentication_ntlm_host']
          http_client_authentication_ntlm_domain repository_config['http_client_authentication_ntlm_domain']
          routing_rule repository_config['routing_rule']
          docker_v1_enabled repository_config['docker_v1_enabled']
          docker_force_basic_auth repository_config['docker_force_basic_auth']
          docker_http_port repository_config['docker_http_port']
          docker_https_port repository_config['docker_https_port']
          docker_subdomain repository_config['docker_subdomain']
          docker_proxy_index_type repository_config['docker_proxy_index_type']
          docker_proxy_index_url repository_config['docker_proxy_index_url']
          docker_proxy_cache_foreign_layers repository_config['docker_proxy_cache_foreign_layers']
          docker_proxy_foreign_layer_url_whitelist repository_config['docker_proxy_foreign_layer_url_whitelist']

          action action
        end
      else
        fail "invalid type #{type}"
      end
    when 'npm'
      case repository_type
      when 'group'
        boxcutter_nexus_npm_group_repository repository_name do
          server_url server_url
          user_name user_name
          password password
          online repository_config['online']
          storage_blob_store_name repository_config['storage_blob_store_name']
          storage_strict_content_type_validation repository_config['storage_strict_content_type_validation']
          group_member_names repository_config['group_member_names']

          action action
        end
      when 'hosted'
        boxcutter_nexus_npm_hosted_repository repository_name do
          server_url server_url
          user_name user_name
          password password
          online repository_config['online']
          storage_blob_store_name repository_config['storage_blob_store_name']
          storage_strict_content_type_validation repository_config['storage_strict_content_type_validation']
          storage_write_policy repository_config['storage_write_policy']

          action action
        end
      when 'proxy'
        boxcutter_nexus_npm_proxy_repository repository_name do
          server_url server_url
          user_name user_name
          password password
          online repository_config['online']
          storage_blob_store_name repository_config['storage_blob_store_name']
          storage_strict_content_type_validation repository_config['storage_strict_content_type_validation']
          proxy_remote_url repository_config['proxy_remote_url']
          proxy_content_max_age repository_config['proxy_content_max_age']
          proxy_metadata_max_age repository_config['proxy_metadata_max_age']
          negative_cache_enabled repository_config['negative_cache_enabled']
          negative_cache_time_to_live repository_config['negative_cache_time_to_live']
          http_client_blocked repository_config['http_client_blocked']
          http_client_auto_block repository_config['http_client_auto_block']
          http_client_connection_retries repository_config['http_client_connection_retries']
          http_client_connection_user_agent_suffix repository_config['http_client_connection_user_agent_suffix']
          http_client_connection_timeout repository_config['http_client_connection_timeout']
          http_client_connection_enable_circular_redirects \
            repository_config['http_client_connection_enable_circular_redirects']
          http_client_connection_enable_cookies repository_config['http_client_connection_enable_cookies']
          http_client_connection_use_trust_store repository_config['http_client_connection_use_trust_store']
          http_client_authentication_type repository_config['http_client_authentication_type']
          http_client_authentication_username repository_config['http_client_authentication_username']
          http_client_authentication_password repository_config['http_client_authentication_password']
          http_client_authentication_ntlm_host repository_config['http_client_authentication_ntlm_host']
          http_client_authentication_ntlm_domain repository_config['http_client_authentication_ntlm_domain']
          routing_rule repository_config['routing_rule']
          npm_remove_quarantined repository_config['npm_remove_quarantined']

          action action
        end
      else
        fail "invalid type #{type}"
      end
    when 'pypi'
      case repository_type
      when 'group'
        boxcutter_nexus_pypi_group_repository repository_name do
          server_url server_url
          user_name user_name
          password password
          online repository_config['online']
          storage_blob_store_name repository_config['storage_blob_store_name']
          storage_strict_content_type_validation repository_config['storage_strict_content_type_validation']
          group_member_names repository_config['group_member_names']

          action action
        end
      when 'hosted'
        boxcutter_nexus_pypi_hosted_repository repository_name do
          server_url server_url
          user_name user_name
          password password
          online repository_config['online']
          storage_blob_store_name repository_config['storage_blob_store_name']
          storage_strict_content_type_validation repository_config['storage_strict_content_type_validation']
          storage_write_policy repository_config['storage_write_policy']

          action action
        end
      when 'proxy'
        boxcutter_nexus_pypi_proxy_repository repository_name do
          server_url server_url
          user_name user_name
          password password
          online repository_config['online']
          storage_blob_store_name repository_config['storage_blob_store_name']
          storage_strict_content_type_validation repository_config['storage_strict_content_type_validation']
          proxy_remote_url repository_config['proxy_remote_url']
          proxy_content_max_age repository_config['proxy_content_max_age']
          proxy_metadata_max_age repository_config['proxy_metadata_max_age']
          negative_cache_enabled repository_config['negative_cache_enabled']
          negative_cache_time_to_live repository_config['negative_cache_time_to_live']
          http_client_blocked repository_config['http_client_blocked']
          http_client_auto_block repository_config['http_client_auto_block']
          http_client_connection_retries repository_config['http_client_connection_retries']
          http_client_connection_user_agent_suffix repository_config['http_client_connection_user_agent_suffix']
          http_client_connection_timeout repository_config['http_client_connection_timeout']
          http_client_connection_enable_circular_redirects \
            repository_config['http_client_connection_enable_circular_redirects']
          http_client_connection_enable_cookies repository_config['http_client_connection_enable_cookies']
          http_client_connection_use_trust_store repository_config['http_client_connection_use_trust_store']
          http_client_authentication_type repository_config['http_client_authentication_type']
          http_client_authentication_username repository_config['http_client_authentication_username']
          http_client_authentication_password repository_config['http_client_authentication_password']
          http_client_authentication_ntlm_host repository_config['http_client_authentication_ntlm_host']
          http_client_authentication_ntlm_domain repository_config['http_client_authentication_ntlm_domain']
          routing_rule repository_config['routing_rule']
          pypi_remove_quarantined repository_config['pypi_remove_quarantined']

          action action
        end
      else
        fail "invalid type #{type}"
      end
    when 'raw'
      case repository_type
      when 'group'
        boxcutter_nexus_raw_group_repository repository_name do
          server_url server_url
          user_name user_name
          password password
          online repository_config['online']
          storage_blob_store_name repository_config['storage_blob_store_name']
          storage_strict_content_type_validation repository_config['storage_strict_content_type_validation']
          group_member_names repository_config['group_member_names']

          action action
        end
      when 'hosted'
        boxcutter_nexus_raw_hosted_repository repository_name do
          server_url server_url
          user_name user_name
          password password
          online repository_config['online']
          storage_blob_store_name repository_config['storage_blob_store_name']
          storage_strict_content_type_validation repository_config['storage_strict_content_type_validation']
          storage_write_policy repository_config['storage_write_policy']

          action action
        end
      when 'proxy'
        boxcutter_nexus_raw_proxy_repository repository_name do
          server_url server_url
          user_name user_name
          password password
          online repository_config['online']
          storage_blob_store_name repository_config['storage_blob_store_name']
          storage_strict_content_type_validation repository_config['storage_strict_content_type_validation']
          proxy_remote_url repository_config['proxy_remote_url']
          proxy_content_max_age repository_config['proxy_content_max_age']
          proxy_metadata_max_age repository_config['proxy_metadata_max_age']
          negative_cache_enabled repository_config['negative_cache_enabled']
          negative_cache_time_to_live repository_config['negative_cache_time_to_live']
          http_client_blocked repository_config['http_client_blocked']
          http_client_auto_block repository_config['http_client_auto_block']
          http_client_connection_retries repository_config['http_client_connection_retries']
          http_client_connection_user_agent_suffix repository_config['http_client_connection_user_agent_suffix']
          http_client_connection_timeout repository_config['http_client_connection_timeout']
          http_client_connection_enable_circular_redirects \
            repository_config['http_client_connection_enable_circular_redirects']
          http_client_connection_enable_cookies repository_config['http_client_connection_enable_cookies']
          http_client_connection_use_trust_store repository_config['http_client_connection_use_trust_store']
          http_client_authentication_type repository_config['http_client_authentication_type']
          http_client_authentication_username repository_config['http_client_authentication_username']
          http_client_authentication_password repository_config['http_client_authentication_password']
          http_client_authentication_ntlm_host repository_config['http_client_authentication_ntlm_host']
          http_client_authentication_ntlm_domain repository_config['http_client_authentication_ntlm_domain']
          routing_rule repository_config['routing_rule']

          action action
        end
      else
        fail "invalid type #{type}"
      end
    else
      fail "invalid format #{repository_format}"
    end
  end
end
