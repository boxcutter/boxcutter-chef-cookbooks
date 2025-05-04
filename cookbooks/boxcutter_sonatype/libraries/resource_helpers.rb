require 'uri'

module Boxcutter
  class Sonatype
    module Resource
      module Helpers
        def self.repository_get(new_resource, format, type)
          base_url = new_resource.server_url
          api_path = "/service/rest/v1/repositories/#{format}/#{type}/#{new_resource.repository_name}"
          uri = URI.join(base_url.chomp('/') + '/', api_path)

          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = (uri.scheme == 'https')

          request = Net::HTTP::Get.new(uri)
          request.basic_auth(new_resource.user_name, new_resource.password)

          response = http.request(request)
          puts "MISCHA: GET response.code=#{response.code}, reponse=#{response.inspect}"

          case response
          when Net::HTTPSuccess
            JSON.parse(response.body)
          else
            fail "Error #{response.code}: #{response.message} — #{response.body}"
          end
        end

        def self.repository_exist?(new_resource, format, type)
          puts "MISCHA: raw_hosted_repository_exist? repository_name=#{new_resource.repository_name}"
          response = nil
          begin
            response = repository_get(new_resource, format, type)
            puts "MISCHA: response=#{response}"
          rescue StandardError => e
            puts "Rescue: #{e.message}"
            puts 'MISCHA: returning false'
            return false
          end

          if response['format'] != format
            fail "format != #{format}"
          end
          if response['type'] != type
            fail "type != #{type}"
          end

          puts 'MISCHA: returning true'
          true
        end

        def self.raw_group_repository_payload(new_resource)
          {
            'name' => new_resource.repository_name,
            'online' => new_resource.online,
            'storage' => {
              'blobStoreName' => new_resource.storage_blob_store_name,
              'strictContentTypeValidation' => new_resource.storage_strict_content_type_validation,
            },
            'group' => {
              'memberNames' => new_resource.group_member_names,
            },
          }.to_json
        end

        def self.raw_hosted_repository_payload(new_resource)
          {
            'name' => new_resource.repository_name,
            'online' => new_resource.online,
            'storage' => {
              'blobStoreName' => new_resource.storage_blob_store_name,
              'strictContentTypeValidation' => new_resource.storage_strict_content_type_validation,
              'writePolicy' => new_resource.storage_write_policy,
            },
            'cleanup' => {
              'policyNames' => [],
            },
          }.to_json
        end

        def self.raw_proxy_repository_payload(new_resource)
          # Cannot do this inline, define the connection hash before,
          # so we can check its contents
          connection = {
            'retries' => new_resource.http_client_connection_retries,
            'userAgentSuffix' => new_resource.http_client_connection_user_agent_suffix,
            'timeout' => new_resource.http_client_connection_timeout,
            'enableCircularRedirects' => new_resource.http_client_connection_enable_circular_redirects,
            'enableCookies' => new_resource.http_client_connection_enable_cookies,
            'useTrustStore' => new_resource.http_client_connection_use_trust_store,
          }.compact

          authentication = {
            'type' => new_resource.http_client_authentication_type,
            'username' => new_resource.http_client_authentication_username,
            'password' => new_resource.http_client_authentication_password,
            'ntlmHost' => new_resource.http_client_authentication_ntlm_host,
            'ntlmDomain' => new_resource.http_client_authentication_ntlm_domain,
            # 'bearerToken' => new_resource.http_client_authentication_bearer_token,
          }.compact

          {
            'name' => new_resource.repository_name,
            'online' => new_resource.online,
            'storage' => {
              'blobStoreName' => new_resource.storage_blob_store_name,
              'strictContentTypeValidation' => new_resource.storage_strict_content_type_validation,
            },
            'proxy' => {
              'remoteUrl' => new_resource.proxy_remote_url,
              'contentMaxAge' => new_resource.proxy_content_max_age,
              'metadataMaxAge' => new_resource.proxy_metadata_max_age,
            },
            'negativeCache' => {
              'enabled' => new_resource.negative_cache_enabled,
              'timeToLive' => new_resource.negative_cache_time_to_live,
            },
            'httpClient' => {
              'blocked' => new_resource.http_client_blocked,
              'autoBlock' => new_resource.http_client_auto_block,
            }.merge(
              connection.empty? ? {} : { 'connection' => connection },
            ).merge(authentication.empty? ? {} : { 'authentication' => authentication }),
          }.to_json
        end

        def self.apt_hosted_repository_payload(new_resource)
          {
            'name' => new_resource.repository_name,
            'online' => new_resource.online,
            'storage' => {
              'blobStoreName' => new_resource.storage_blob_store_name,
              'strictContentTypeValidation' => new_resource.storage_strict_content_type_validation,
              'writePolicy' => new_resource.storage_write_policy,
            },
            'cleanup' => {
              'policyNames' => [],
            },
          }.to_json
        end

        def self.apt_proxy_repository_payload(new_resource)
          # Cannot do this inline, define the connection hash before,
          # so we can check its contents
          connection = {
            'retries' => new_resource.http_client_connection_retries,
            'userAgentSuffix' => new_resource.http_client_connection_user_agent_suffix,
            'timeout' => new_resource.http_client_connection_timeout,
            'enableCircularRedirects' => new_resource.http_client_connection_enable_circular_redirects,
            'enableCookies' => new_resource.http_client_connection_enable_cookies,
            'useTrustStore' => new_resource.http_client_connection_use_trust_store,
          }.compact

          authentication = {
            'type' => new_resource.http_client_authentication_type,
            'username' => new_resource.http_client_authentication_username,
            'password' => new_resource.http_client_authentication_password,
            'ntlmHost' => new_resource.http_client_authentication_ntlm_host,
            'ntlmDomain' => new_resource.http_client_authentication_ntlm_domain,
            # 'bearerToken' => new_resource.http_client_authentication_bearer_token,
          }.compact

          {
            'name' => new_resource.repository_name,
            'online' => new_resource.online,
            'storage' => {
              'blobStoreName' => new_resource.storage_blob_store_name,
              'strictContentTypeValidation' => new_resource.storage_strict_content_type_validation,
            },
            'proxy' => {
              'remoteUrl' => new_resource.proxy_remote_url,
              'contentMaxAge' => new_resource.proxy_content_max_age,
              'metadataMaxAge' => new_resource.proxy_metadata_max_age,
            },
            'negativeCache' => {
              'enabled' => new_resource.negative_cache_enabled,
              'timeToLive' => new_resource.negative_cache_time_to_live,
            },
            'httpClient' => {
              'blocked' => new_resource.http_client_blocked,
              'autoBlock' => new_resource.http_client_auto_block,
            }.merge(
              connection.empty? ? {} : { 'connection' => connection },
            ).merge(authentication.empty? ? {} : { 'authentication' => authentication }),
            'apt' => {
              'distribution' => new_resource.apt_distribution,
              'flat' => new_resource.apt_flat,
            },
          }.to_json
        end

        def self.pypi_group_repository_payload(new_resource)
          {
            'name' => new_resource.repository_name,
            'online' => new_resource.online,
            'storage' => {
              'blobStoreName' => new_resource.storage_blob_store_name,
              'strictContentTypeValidation' => new_resource.storage_strict_content_type_validation,
            },
            'group' => {
              'memberNames' => new_resource.group_member_names,
            },
          }.to_json
        end

        def self.pypi_hosted_repository_payload(new_resource)
          {
            'name' => new_resource.repository_name,
            'online' => new_resource.online,
            'storage' => {
              'blobStoreName' => new_resource.storage_blob_store_name,
              'strictContentTypeValidation' => new_resource.storage_strict_content_type_validation,
              'writePolicy' => new_resource.storage_write_policy,
            },
            'cleanup' => {
              'policyNames' => [],
            },
          }.to_json
        end

        def self.pypi_proxy_repository_payload(new_resource)
          # Cannot do this inline, define the connection hash before,
          # so we can check its contents
          connection = {
            'retries' => new_resource.http_client_connection_retries,
            'userAgentSuffix' => new_resource.http_client_connection_user_agent_suffix,
            'timeout' => new_resource.http_client_connection_timeout,
            'enableCircularRedirects' => new_resource.http_client_connection_enable_circular_redirects,
            'enableCookies' => new_resource.http_client_connection_enable_cookies,
            'useTrustStore' => new_resource.http_client_connection_use_trust_store,
          }.compact

          authentication = {
            'type' => new_resource.http_client_authentication_type,
            'username' => new_resource.http_client_authentication_username,
            'password' => new_resource.http_client_authentication_password,
            'ntlmHost' => new_resource.http_client_authentication_ntlm_host,
            'ntlmDomain' => new_resource.http_client_authentication_ntlm_domain,
            # 'bearerToken' => new_resource.http_client_authentication_bearer_token,
          }.compact

          {
            'name' => new_resource.repository_name,
            'online' => new_resource.online,
            'storage' => {
              'blobStoreName' => new_resource.storage_blob_store_name,
              'strictContentTypeValidation' => new_resource.storage_strict_content_type_validation,
            },
            'proxy' => {
              'remoteUrl' => new_resource.proxy_remote_url,
              'contentMaxAge' => new_resource.proxy_content_max_age,
              'metadataMaxAge' => new_resource.proxy_metadata_max_age,
            },
            'negativeCache' => {
              'enabled' => new_resource.negative_cache_enabled,
              'timeToLive' => new_resource.negative_cache_time_to_live,
            },
            'httpClient' => {
              'blocked' => new_resource.http_client_blocked,
              'autoBlock' => new_resource.http_client_auto_block,
            }.merge(
              connection.empty? ? {} : { 'connection' => connection },
            ).merge(authentication.empty? ? {} : { 'authentication' => authentication }),
            'pypi' => {
              'removeQuarantined' => new_resource.pypi_remove_quarantined,
            },
          }.to_json
        end

        def self.docker_group_repository_payload(new_resource)
          {
            'name' => new_resource.repository_name,
            'online' => new_resource.online,
            'storage' => {
              'blobStoreName' => new_resource.storage_blob_store_name,
              'strictContentTypeValidation' => new_resource.storage_strict_content_type_validation,
            },
            'group' => {
              'memberNames' => new_resource.group_member_names,
              'writableMember' => new_resource.group_writable_member,
            },
            'docker' => {
              'v1Enabled' => new_resource.docker_v1_enabled,
              'forceBasicAuth' => new_resource.docker_force_basic_auth,
              'httpPort' => new_resource.docker_http_port,
              'httpsPort' => new_resource.docker_https_port,
              'subdomain' => new_resource.docker_subdomain,
            },
          }.to_json
        end

        def self.docker_hosted_repository_payload(new_resource)
          {
            'name' => new_resource.repository_name,
            'online' => new_resource.online,
            'storage' => {
              'blobStoreName' => new_resource.storage_blob_store_name,
              'strictContentTypeValidation' => new_resource.storage_strict_content_type_validation,
              'writePolicy' => new_resource.storage_write_policy,
              'latestPolicy' => new_resource.storage_latest_policy,
            },
            'cleanup' => {
              'policyNames' => [],
            },
            'docker' => {
              'v1Enabled' => new_resource.docker_v1_enabled,
              'forceBasicAuth' => new_resource.docker_force_basic_auth,
              'httpPort' => new_resource.docker_http_port,
              'httpsPort' => new_resource.docker_https_port,
              'subdomain' => new_resource.docker_subdomain,
            },
          }.to_json
        end

        def self.docker_proxy_repository_payload(new_resource)
          # Cannot do this inline, define the connection hash before,
          # so we can check its contents
          connection = {
            'retries' => new_resource.http_client_connection_retries,
            'userAgentSuffix' => new_resource.http_client_connection_user_agent_suffix,
            'timeout' => new_resource.http_client_connection_timeout,
            'enableCircularRedirects' => new_resource.http_client_connection_enable_circular_redirects,
            'enableCookies' => new_resource.http_client_connection_enable_cookies,
            'useTrustStore' => new_resource.http_client_connection_use_trust_store,
          }.compact

          authentication = {
            'type' => new_resource.http_client_authentication_type,
            'username' => new_resource.http_client_authentication_username,
            'password' => new_resource.http_client_authentication_password,
            'ntlmHost' => new_resource.http_client_authentication_ntlm_host,
            'ntlmDomain' => new_resource.http_client_authentication_ntlm_domain,
            # 'bearerToken' => new_resource.http_client_authentication_bearer_token,
          }.compact

          {
            'name' => new_resource.repository_name,
            'online' => new_resource.online,
            'storage' => {
              'blobStoreName' => new_resource.storage_blob_store_name,
              'strictContentTypeValidation' => new_resource.storage_strict_content_type_validation,
            },
            'proxy' => {
              'remoteUrl' => new_resource.proxy_remote_url,
              'contentMaxAge' => new_resource.proxy_content_max_age,
              'metadataMaxAge' => new_resource.proxy_metadata_max_age,
            },
            'negativeCache' => {
              'enabled' => new_resource.negative_cache_enabled,
              'timeToLive' => new_resource.negative_cache_time_to_live,
            },
            'httpClient' => {
              'blocked' => new_resource.http_client_blocked,
              'autoBlock' => new_resource.http_client_auto_block,
            }.merge(
              connection.empty? ? {} : { 'connection' => connection },
            ).merge(authentication.empty? ? {} : { 'authentication' => authentication }),
            'docker' => {
              'v1Enabled' => new_resource.docker_v1_enabled,
              'forceBasicAuth' => new_resource.docker_force_basic_auth,
              'httpPort' => new_resource.docker_http_port,
              'httpsPort' => new_resource.docker_https_port,
              'subdomain' => new_resource.docker_subdomain,
            },
            'dockerProxy' => {
              'indexType' => new_resource.docker_proxy_index_type,
              'indexUrl' => new_resource.docker_proxy_index_url,
              'cacheForeignLayers' => new_resource.docker_proxy_cache_foreign_layers,
              'foreignLayerUrlWhitelist' => new_resource.docker_proxy_foreign_layer_url_whitelist,
            },
          }.to_json
        end

        def self.repository_create(new_resource, format, type)
          base_url = new_resource.server_url
          api_path = "/service/rest/v1/repositories/#{format}/#{type}"
          uri = URI.join(base_url.chomp('/') + '/', api_path)

          case format
          when 'raw'
            case type
            when 'hosted'
              payload = raw_hosted_repository_payload(new_resource)
            when 'proxy'
              payload = raw_proxy_repository_payload(new_resource)
            when 'group'
              payload = raw_group_repository_payload(new_resource)
            else
              fail "invalid type #{type}"
            end
          when 'apt'
            case type
            when 'hosted'
              payload = apt_hosted_repository_payload(new_resource)
            when 'proxy'
              payload = apt_proxy_repository_payload(new_resource)
            else
              fail "invalid type #{type}"
            end
          when 'pypi'
            case type
            when 'hosted'
              payload = pypi_hosted_repository_payload(new_resource)
            when 'proxy'
              payload = pypi_proxy_repository_payload(new_resource)
            when 'group'
              payload = pypi_group_repository_payload(new_resource)
            else
              fail "invalid type #{type}"
            end
          when 'docker'
            case type
            when 'hosted'
              payload = docker_hosted_repository_payload(new_resource)
            when 'proxy'
              payload = docker_proxy_repository_payload(new_resource)
            when 'group'
              payload = docker_group_repository_payload(new_resource)
            else
              fail "invalid type #{type}"
            end
          else
            fail "invalid format #{format}"
          end

          puts "MISCHA: payload=#{payload.inspect}"

          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = (uri.scheme == 'https')

          request = Net::HTTP::Post.new(uri)
          request.content_type = 'application/json'
          request.basic_auth(new_resource.user_name, new_resource.password)
          request.body = payload

          response = http.request(request)

          puts "MISCHA: POST response code: #{response.code}"
          puts "MISCHA: POST response body: #{response.body}"
        end

        def self.repository_update(new_resource, format, type)
          base_url = new_resource.server_url
          api_path = "/service/rest/v1/repositories/#{format}/#{type}/#{new_resource.repository_name}"
          uri = URI.join(base_url.chomp('/') + '/', api_path)

          case format
          when 'raw'
            case type
            when 'hosted'
              payload = raw_hosted_repository_payload(new_resource)
            when 'proxy'
              payload = raw_proxy_repository_payload(new_resource)
            when 'group'
              payload = raw_group_repository_payload(new_resource)
            else
              fail "invalid type #{type}"
            end
          when 'apt'
            case type
            when 'hosted'
              payload = apt_hosted_repository_payload(new_resource)
            when 'proxy'
              payload = apt_proxy_repository_payload(new_resource)
            else
              fail "invalid type #{type}"
            end
          when 'pypi'
            case type
            when 'hosted'
              payload = pypi_hosted_repository_payload(new_resource)
            when 'proxy'
              payload = pypi_proxy_repository_payload(new_resource)
            when 'group'
              payload = pypi_group_repository_payload(new_resource)
            else
              fail "invalid type #{type}"
            end
          when 'docker'
            case type
            when 'hosted'
              payload = docker_hosted_repository_payload(new_resource)
            when 'proxy'
              payload = docker_proxy_repository_payload(new_resource)
            when 'group'
              payload = docker_group_repository_payload(new_resource)
            else
              fail "invalid type #{type}"
            end
          else
            fail "invalid format #{format}"
          end

          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = (uri.scheme == 'https')

          request = Net::HTTP::Put.new(uri)
          request.content_type = 'application/json'
          request.basic_auth(new_resource.user_name, new_resource.password)
          request.body = payload

          puts "MISCHA: payload=#{payload.inspect}"

          response = http.request(request)

          case response
          when Net::HTTPSuccess, Net::HTTPNoContent
            puts "Repository '#{new_resource.repository_name}' updated successfully."
          else
            fail "Update failed: #{response.code} #{response.message} — #{response.body}"
          end
        end

        def self.repository_delete(new_resource)
          base_url = new_resource.server_url
          api_path = "/service/rest/v1/repositories/#{new_resource.repository_name}"
          uri = URI.join(base_url.chomp('/') + '/', api_path)

          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = (uri.scheme == 'https')

          request = Net::HTTP::Delete.new(uri)
          request.basic_auth(new_resource.user_name, new_resource.password)

          response = http.request(request)

          puts "MISCHA: DELETE response code: #{response.code}"

          case response
          when Net::HTTPNoContent
            puts "Repository '#{new_resource.repository_name}' deleted successfully."
          when Net::HTTPNotFound
            puts "Repository '#{new_resource.repository_name}' does not exist."
          else
            fail "Failed to delete repo: #{response.code} #{response.message} — #{response.body}"
          end
        end
      end
    end
  end
end
