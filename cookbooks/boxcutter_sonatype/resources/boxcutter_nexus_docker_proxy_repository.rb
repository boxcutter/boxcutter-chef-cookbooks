unified_mode true
provides :boxcutter_nexus_docker_proxy_repository

property :repository_name, String, name_property: true
property :server_url, String
property :user_name, String
property :password, String
property :online, [TrueClass, FalseClass], default: true
property :storage_blob_store_name, String, default: 'default',
         description: 'Blob store used to store repository contents'
property :storage_strict_content_type_validation, [TrueClass, FalseClass], default: false,
         description: 'Validate that all content uploaded to this repository is of a MIME type appropriate for the repository format'
# property :cleanup_policy_names, Array
property :proxy_remote_url, String,
         description: 'Location of the remote repository being proxied'
property :proxy_content_max_age, Integer, default: 1440,
         description: 'How long (in minutes) to cache artifacts before rechecking the remote repository. Release repositories should use -1.'
property :proxy_metadata_max_age, Integer, default: 1440,
         description: 'How long (in minutes) to cache metadata before rechecking the remote repository.'
property :negative_cache_enabled, [TrueClass, FalseClass], default: true,
         description: 'Cache responses for content not present in the proxied repository'
property :negative_cache_time_to_live, Integer, default: 1440,
         description: 'How long to cache the fact that a file was not found in the repository (in minutes)'
property :http_client_blocked, [TrueClass, FalseClass], default: false,
         description: 'Block outbound connections on the repository'
property :http_client_auto_block, [TrueClass, FalseClass], default: true,
         description: 'Auto-block outbound connections on the repository if remote peer is detected as unreachable/unresponsive'
property :http_client_connection_retries, Integer,
         description: 'Total retries if the initial connection attempt suffers a timeout'
property :http_client_connection_user_agent_suffix, String,
         description: 'Custom fragment to append to "User-Agent" header in HTTP requests'
property :http_client_connection_timeout, Integer,
         description: 'Seconds to wait for activity before stopping and retrying the connection. Leave blank to use the globally defined HTTP timeout.'
property :http_client_connection_enable_circular_redirects, [TrueClass, FalseClass], default: false,
         description: 'Enable redirects to the same location (may be required by some servers)'
property :http_client_connection_enable_cookies, [TrueClass, FalseClass], default: false,
         description: 'Allow cookies to be stored and used'
property :http_client_connection_use_trust_store, [TrueClass, FalseClass], default: false,
         description: 'Use certificates stored in the Nexus Repository truststore to connect to external system'
property :http_client_authentication_type,
         equal_to: %w[username ntlm]
property :http_client_authentication_username, String
property :http_client_authentication_password, String
property :http_client_authentication_ntlm_host, String
property :http_client_authentication_ntlm_domain, String
# https://github.com/sonatype/nexus-public/issues/540
# property :http_client_authentication_bearer_token
property :routing_rule
# property :replication_preemptive_pull_enabled
# property :replication_asset_path_regex
property :docker_v1_enabled, [TrueClass, FalseClass], default: false
property :docker_force_basic_auth, [TrueClass, FalseClass], default: true
property :docker_http_port, Integer
property :docker_https_port, Integer
property :docker_subdomain, String
property :docker_proxy_index_type, String
property :docker_proxy_index_url, String
property :docker_proxy_cache_foreign_layers, [TrueClass, FalseClass]
property :docker_proxy_foreign_layer_url_whitelist, Array, default: []

load_current_value do |new_resource|
  response = nil
  begin
    response = Boxcutter::Sonatype::Resource::Helpers.repository_get(new_resource, 'docker', 'proxy')
  rescue
    current_value_does_not_exist!
  end

  if response['format'] != 'docker'
    raise 'format != docker'
  end
  if response['type'] != 'proxy'
    raise 'type != proxy'
  end
  repository_name response['name']
  online response['online']
  storage_blob_store_name response['storage']['blobStoreName']
  storage_strict_content_type_validation response['storage']['strictContentTypeValidation']
  proxy_remote_url response['proxy']['remoteUrl']
  proxy_content_max_age response['proxy']['contentMaxAge']
  proxy_metadata_max_age response['proxy']['metadataMaxAge']
  negative_cache_enabled response['negativeCache']['enabled']
  negative_cache_time_to_live response['negativeCache']['timeToLive']
  http_client_blocked response['httpClient']['blocked']
  http_client_auto_block response['httpClient']['autoBlock']
  http_client_connection_retries response['httpClient']['connection']['retries']
  http_client_connection_user_agent_suffix response['httpClient']['connection']['userAgentSuffix']
  http_client_connection_timeout response['httpClient']['connection']['timeout']
  http_client_connection_enable_circular_redirects response['httpClient']['connection']['enableCircularRedirects']
  http_client_connection_enable_cookies response['httpClient']['connection']['enableCookies']
  http_client_connection_use_trust_store response['httpClient']['connection']['useTrustStore']
  if response.dig('httpClient', 'authentication', 'type')
    http_client_authentication_type response['httpClient']['authentication']['type']
  end
  if response.dig('httpClient', 'authentication', 'username')
    http_client_authentication_username response['httpClient']['authentication']['username']
  end
  if response.dig('httpClient', 'authentication', 'password')
    http_client_authentication_password response['httpClient']['authentication']['password']
  end
  if response.dig('httpClient', 'authentication', 'ntlmHost')
    http_client_authentication_ntlm_host response['httpClient']['authentication']['ntlmHost']
  end
  if response.dig('httpClient', 'authentication', 'ntlmDomain')
    http_client_authentication_ntlm_domain response['httpClient']['authentication']['ntlmDomain']
  end
  # http_client_authentication_bearer_token response['httpClient']['authentication']['bearerToken']
  routing_rule response['routingRuleName']
  docker_v1_enabled response['docker']['v1Enabled']
  docker_force_basic_auth response['docker']['forceBasicAuth']
  docker_http_port response['docker']['httpPort']
  docker_https_port response['docker']['httpsPort']
  docker_subdomain response['docker']['subdomain']
  docker_proxy_index_type response['dockerProxy']['indexType']
  docker_proxy_index_url response['dockerProxy']['indexUrl']
  docker_proxy_cache_foreign_layers response['dockerProxy']['cacheForeignLayers']
  docker_proxy_foreign_layer_url_whitelist response['dockerProxy']['foreignLayerUrlWhitelist']

  puts "MISCHA: boxcutter_nexus_docker_proxy_repository::load_current_value #{response}"
end

action_class do
  include Boxcutter::Sonatype::Resource::Helpers
end

action :create do
  repository_exist = Boxcutter::Sonatype::Resource::Helpers.repository_exist?(new_resource, 'docker', 'proxy')
  puts "MISCHA boxcutter_nexus_docker_proxy_repository::create repository_exist=#{repository_exist}"
  unless repository_exist
    converge_if_changed do
      Boxcutter::Sonatype::Resource::Helpers.repository_create(new_resource, 'docker', 'proxy')
    end
  end
end

action :update do
  repository_exist = Boxcutter::Sonatype::Resource::Helpers.repository_exist?(new_resource, 'docker', 'proxy')
  puts "MISCHA boxcutter_nexus_pypi_proxy_repository::update repository_exist=#{repository_exist}"
  unless repository_exist
    raise Chef::Exceptions::CurrentValueDoesNotExist, "Cannot update repository'#{new_resource.repository_name}' as it does not exist"
  end
  converge_if_changed(
    :online,
    :storage_blob_store_name,
    :storage_strict_content_type_validation,
    :proxy_remote_url,
    :proxy_content_max_age,
    :proxy_metadata_max_age,
    :negative_cache_enabled,
    :negative_cache_time_to_live,
    :http_client_blocked,
    :http_client_auto_block,
    :http_client_connection_retries,
    :http_client_connection_user_agent_suffix,
    :http_client_connection_timeout,
    :http_client_connection_enable_circular_redirects,
    :http_client_connection_enable_cookies,
    :http_client_connection_use_trust_store,
    :http_client_authentication_type,
    :http_client_authentication_username,
    :http_client_authentication_password,
    :http_client_authentication_ntlm_host,
    :http_client_authentication_ntlm_domain,
    :docker_v1_enabled,
    :docker_force_basic_auth,
    :docker_http_port,
    :docker_https_port,
    :docker_subdomain,
    :docker_proxy_index_type,
    :docker_proxy_index_url,
    :docker_proxy_cache_foreign_layers,
    :docker_proxy_foreign_layer_url_whitelist,
  ) do
    Boxcutter::Sonatype::Resource::Helpers.repository_update(new_resource, 'docker', 'proxy')
  end
end

action :delete do
  repository_exist = Boxcutter::Sonatype::Resource::Helpers.repository_exist?(new_resource, 'docker', 'proxy')
  puts "MISCHA boxcutter_nexus_docker_proxy_repository::delete repository_exist=#{repository_exist}"
  if repository_exist
    converge_by("Delete repository #{new_resource.repository_name}") do
      Boxcutter::Sonatype::Resource::Helpers.repository_delete(new_resource)
    end
  end
end