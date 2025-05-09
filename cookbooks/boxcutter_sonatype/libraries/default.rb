module Boxcutter
  class Sonatype
    module Helpers
      def self.run_state_or_attribute(node, attribute)
        if node.run_state.key?('boxcutter_sonatype') \
          && node.run_state['boxcutter_sonatype']['nexus_repository'] \
          && node.run_state['boxcutter_sonatype']['nexus_repository'].key?(attribute)
          node.run_state['boxcutter_sonatype']['nexus_repository'][attribute]
        else
          node['boxcutter_sonatype']['nexus_repository'][attribute]
        end
      end

      def self.admin_username(node)
        run_state_or_attribute(node, 'admin_username')
      end

      def self.admin_password(node)
        run_state_or_attribute(node, 'admin_password')
      end

      # curl -u admin:password \
      #   -H "accept: application/json" \
      #   -X GET 'http://127.0.0.1:8081/service/rest/v1/security/realms/active'
      def self.get_realms_active(node)
        uri = URI.parse('http://localhost:8081/service/rest/v1/security/realms/active')
        request = Net::HTTP::Get.new(uri)
        request.basic_auth(admin_username(node), admin_password(node))
        request['Accept'] = 'application/json'

        response = Net::HTTP.start(uri.hostname, uri.port) do |http|
          http.request(request)
        end

        if response.is_a?(Net::HTTPSuccess)
          active_realms = JSON.parse(response.body)
          Chef::Log.info("Active Realms: #{active_realms}")
        else
          Chef::Log.error("Failed to query active realms. HTTP Status: #{response.code}")
        end
        active_realms
      end

      # curl -u admin:password \
      #   -H "Content-Type: application/json" \
      #   -X PUT "http://127.0.0.1:8081/service/rest/v1/security/realms/active" \
      #   -d '["NexusAuthenticatingRealm", "DockerToken"]'
      def self.set_realms_active(node, realms)
        uri = URI.parse('http://localhost:8081/service/rest/v1/security/realms/active')
        request = Net::HTTP::Put.new(uri)
        request.basic_auth(admin_username(node), admin_password(node))
        request['Content-Type'] = 'application/json'
        request.body = realms.to_json

        response = Net::HTTP.start(uri.hostname, uri.port) do |http|
          http.request(request)
        end

        if response.is_a?(Net::HTTPSuccess)
          puts 'Active realms set successfully.'
        else
          puts "Failed to set active realms. HTTP Status: #{response.code} #{response.message}"
          puts "Response body: #{response.body}"
        end
      end

      # curl -u admin:password \
      #   -H "accept: application/json" \
      #   -X GET 'http://127.0.0.1:8081/service/rest/v1/security/realms/available'
      def self.get_realms_available(node)
        uri = URI.parse('http://localhost:8081/service/rest/v1/security/realms/available')
        request = Net::HTTP::Get.new(uri)
        request.basic_auth(admin_username(node), admin_password(node))
        request['Accept'] = 'application/json'

        response = Net::HTTP.start(uri.hostname, uri.port) do |http|
          http.request(request)
        end

        if response.is_a?(Net::HTTPSuccess)
          available_realms = JSON.parse(response.body)
          Chef::Log.info("Available Realms: #{available_realms}")
        else
          Chef::Log.error("Failed to query available realms. HTTP Status: #{response.code}")
        end
        available_realms
      end

      # curl -u admin:Superseekret63 \
      #   -H "Content-Type: application/json" \
      #   -X GET "http://localhost:8081/service/rest/v1/security/roles"
      def self.roles_list(node)
        uri = URI.parse('http://localhost:8081/service/rest/v1/security/roles')
        request = Net::HTTP::Get.new(uri)
        request.basic_auth(admin_username(node), admin_password(node))
        request['Accept'] = 'application/json'

        response = Net::HTTP.start(uri.hostname, uri.port) do |http|
          http.request(request)
        end

        if response.code.to_i == 200
          roles = JSON.parse(response.body)
          Chef::Log.info("Roles: #{roles}")
          # You can process the repositories as needed here
        else
          Chef::Log.error("Failed to get roles: #{response.message}")
        end
        roles
      end

      def self.role_create_payload(role_id, role_config)
        {
          'id' => role_id,
          'name' => role_config['name'],
          'description' => role_config['description'],
          'privileges' => role_config['privileges'],
          'roles' => role_config['roles'],
        }.to_json
      end

      def self.role_create(node, role_id, role_config)
        uri = URI.parse('http://localhost:8081/service/rest/v1/security/roles')

        payload = role_create_payload(role_id, role_config)
        puts "MISCHA: role_create_payload: #{payload}"

        http = Net::HTTP.new(uri.host, uri.port)

        request = Net::HTTP::Post.new(uri.request_uri, { 'Content-Type' => 'application/json' })
        request.basic_auth(admin_username(node), admin_password(node))
        request.body = payload

        response = http.request(request)

        puts "MISCHA: PUT response code: #{response.code}"
        puts "MISCHA: PUT response body: #{response.body}"
      end

      def self.role_delete(node, role_id)
        uri = URI.parse("http://localhost:8081/service/rest/v1/security/roles/#{role_id}")
        http = Net::HTTP.new(uri.hostname, uri.port)

        request = Net::HTTP::Delete.new(uri)
        request.basic_auth(admin_username(node), admin_password(node))

        response = http.request(request)

        puts "MISCHA: DELETE response code: #{response.code}"
        puts "MISCHA: DELETE response body: #{response.body}"
      end

      # curl -u admin:password \
      #   -H "Content-Type: application/json" \
      #   -X GET "http://localhost:8081/service/rest/v1/security/users"
      def self.users_list(node)
        uri = URI.parse('http://localhost:8081/service/rest/v1/security/users')
        request = Net::HTTP::Get.new(uri)
        request.basic_auth(admin_username(node), admin_password(node))
        request['Accept'] = 'application/json'

        response = Net::HTTP.start(uri.hostname, uri.port) do |http|
          http.request(request)
        end

        if response.code.to_i == 200
          users = JSON.parse(response.body)
          Chef::Log.info("Users: #{users}")
          # You can process the repositories as needed here
        else
          Chef::Log.error("Failed to get repositories: #{response.message}")
        end
        users
      end

      def self.user_create_payload(user_id, user_config)
        {
          'userId' => user_id,
          'firstName' => user_config['first_name'],
          'lastName' => user_config['last_name'],
          'emailAddress' => user_config['email_address'],
          'password' => user_config['password'],
          'status' => 'active',
          'roles' => user_config['roles'],
        }.to_json
      end

      def self.user_create(node, user_id, user_config)
        uri = URI.parse('http://localhost:8081/service/rest/v1/security/users')

        payload = user_create_payload(user_id, user_config)
        puts "MISCHA: user_create_payload: #{payload}"

        http = Net::HTTP.new(uri.host, uri.port)

        request = Net::HTTP::Post.new(uri.request_uri, { 'Content-Type' => 'application/json' })
        request.basic_auth(admin_username(node), admin_password(node))
        request.body = payload

        response = http.request(request)

        puts "MISCHA: PUT response code: #{response.code}"
        puts "MISCHA: PUT response body: #{response.body}"
      end

      def self.user_delete(node, user_id)
        uri = URI.parse("http://localhost:8081/service/rest/v1/security/users/#{user_id}")
        http = Net::HTTP.new(uri.hostname, uri.port)

        request = Net::HTTP::Delete.new(uri)
        request.basic_auth(admin_username(node), admin_password(node))

        response = http.request(request)

        puts "MISCHA: DELETE response code: #{response.code}"
        puts "MISCHA: DELETE response body: #{response.body}"
      end

      def self.change_user_password(user_id, new_password); end

      # curl -ifu admin:Superseekret63 \
      #   -X GET 'http://127.0.0.1:8081/service/rest/v1/repositories'
      def self.repositories_list(node)
        uri = URI.parse('http://localhost:8081/service/rest/v1/repositories')
        request = Net::HTTP::Get.new(uri)
        request.basic_auth(admin_username(node), admin_password(node))
        request['Accept'] = 'application/json'

        response = Net::HTTP.start(uri.hostname, uri.port) do |http|
          http.request(request)
        end

        if response.code.to_i == 200
          repositories = JSON.parse(response.body)
          Chef::Log.info("Repositories: #{repositories}")
          # You can process the repositories as needed here
        else
          Chef::Log.error("Failed to get repositories: #{response.message}")
        end
        repositories
      end

      def self.repositories_settings_list(node)
        uri = URI.parse('http://localhost:8081/service/rest/v1/repositorySettings')
        request = Net::HTTP::Get.new(uri)
        request.basic_auth(admin_username(node), admin_password(node))
        request['Accept'] = 'application/json'

        response = Net::HTTP.start(uri.hostname, uri.port) do |http|
          http.request(request)
        end

        if response.code.to_i == 200
          repositories_settings = JSON.parse(response.body)
          Chef::Log.info("Repositories: #{repositories_settings}")
          # You can process the repositories as needed here
        else
          Chef::Log.error("Failed to get repositories: #{response.message}")
        end
        repositories_settings
      end

      def self.repository_create_apt_payload(repository_name, repository_config)
        case repository_config['type']
        when 'proxy'
          payload = {
            'name' => repository_name,
            'online' => true,
            'storage' => {
              'blobStoreName' => repository_config.fetch('storage_blob_store_name', 'default'),
              'strictContentTypeValidation' => false,
            },
            'cleanup' => {
              'policyNames' => [],
            },
            'proxy' => {
              'remoteUrl' => repository_config['remote_url'],
              'contentMaxAge' => 1440,
              'metadataMaxAge' => 1440,
            },
            'negativeCache' => {
              'enabled' => true,
              'timeToLive' => 1440,
            },
            'httpClient' => {
              'blocked' => false,
              'autoBlock' => true,
              'connection' => {
                'retries' => 0,
                # 'userAgentSuffix' => 'string',
                'timeout' => 60,
                'enableCircularRedirects' => false,
                'enableCookies' => false,
                'useTrustStore' => false,
              },
            },
            'apt' => {
              'distribution' => repository_config['distribution'],
              'flat' => repository_config['flat'],
            },
          }

          if repository_config.key?('authentication_username')
            payload['httpClient']['authentication'] = {
              'type' => 'username',
              'username' => repository_config['authentication_username'],
            }
            if repository_config.key('authentication_password')
              payload['httpClient']['authentication']['password'] = repository_config['authentication_password']
            end
          end

          payload.to_json
        end
      end

      def self.repository_create_docker_payload(repository_name, repository_config)
        case repository_config['type']
        when 'group'
          {
            'name' => repository_name,
            'online' => true,
            'storage' => {
              'blobStoreName' => repository_config.fetch('storage_blob_store_name', 'default'),
              'strictContentTypeValidation' => true,
            },
            'group' => {
              'memberNames' => repository_config['member_names'],
              'writableMember' => repository_config['writable_member'],
            },
            'docker' => {
              'v1Enabled' => repository_config['docker_v1_enabled'],
              'forceBasicAuth' => repository_config['docker_force_basic_auth'],
              'httpPort' => repository_config['docker_http_port'],
              'httpsPort' => repository_config['docker_https_port'],
            },
          }.to_json
        when 'hosted'
          {
            'name' => repository_name,
            'online' => true,
            'storage' => {
              'blobStoreName' => repository_config.fetch('storage_blob_store_name', 'default'),
              'strictContentTypeValidation' => true,
              'writePolicy' => 'allow',
              'latestPolicy' => true,
            },
            'cleanup' => {
              'policyNames' => [],
            },
            'docker' => {
              'v1Enabled' => repository_config['docker_v1_enabled'],
              'forceBasicAuth' => repository_config['docker_force_basic_auth'],
              'httpPort' => repository_config['docker_http_port'],
              'httpsPort' => repository_config['docker_https_port'],
            },
          }.to_json
        when 'proxy'
          {
            'name' => repository_name,
            'online' => true,
            'storage' => {
              'blobStoreName' => repository_config.fetch('storage_blob_store_name', 'default'),
              'strictContentTypeValidation' => true,
            },
            'cleanup' => {
              'policyNames' => [],
            },
            'proxy' => {
              'remoteUrl' => repository_config['remote_url'],
              'contentMaxAge' => 1440,
              'metadataMaxAge' => 1440,
            },
            'negativeCache' => {
              'enabled' => true,
              'timeToLive' => 1440,
            },
            'httpClient' => {
              'blocked' => false,
              'autoBlock' => true,
              'connection' => {
                'retries' => 0,
                # 'userAgentSuffix' => 'string',
                'timeout' => 60,
                'enableCircularRedirects' => false,
                'enableCookies' => false,
                'useTrustStore' => false,
              },
            },
            'docker' => {
              'v1Enabled' => repository_config['docker_v1_enabled'],
              'forceBasicAuth' => repository_config['docker_force_basic_auth'],
              'httpPort' => repository_config['docker_http_port'],
              'httpsPort' => repository_config['docker_https_port'],
            },
            'dockerProxy' => {
              'indexType' => repository_config['docker_proxy_index_type'],
              'indexUrl' => 'https://index.docker.io/',
              # 'indexUrl' => 'string',
              'cacheForeignLayers' => true,
            },
          }.to_json
        end
      end

      def self.repository_create_npm_payload(repository_name, repository_config)
        case repository_config['type']
        when 'hosted'
          {
            'name' => repository_name,
            'online' => true,
            'storage' => {
              'blobStoreName' => repository_config.fetch('storage_blob_store_name', 'default'),
              'strictContentTypeValidation' => true,
              'writePolicy' => 'allow',
            },
            'cleanup' => {
              'policyNames' => [],
            },
          }.to_json
        when 'proxy'
          {
            'name' => repository_name,
            'online' => true,
            'storage' => {
              'blobStoreName' => repository_config.fetch('storage_blob_store_name', 'default'),
              'strictContentTypeValidation' => false,
            },
            'proxy' => {
              'remoteUrl' => repository_config['remote_url'],
              'contentMaxAge' => 1440,
              'metadataMaxAge' => 1440,
            },
            'negativeCache' => {
              'enabled' => true,
              'timeToLive' => 1440,
            },
            'httpClient' => {
              'blocked' => false,
              'autoBlock' => true,
              'connection' => {
                'retries' => 0,
                # 'userAgentSuffix' => 'string',
                'timeout' => 60,
                'enableCircularRedirects' => false,
                'enableCookies' => false,
                'useTrustStore' => false,
              },
            },
          }.to_json
        end
      end

      def self.repository_create_pypi_payload(repository_name, repository_config)
        case repository_config['type']
        when 'hosted'
          {
            'name' => repository_name,
            'online' => true,
            'storage' => {
              'blobStoreName' => repository_config.fetch('storage_blob_store_name', 'default'),
              'strictContentTypeValidation' => true,
              'writePolicy' => 'allow',
            },
            'cleanup' => {
              'policyNames' => [],
            },
          }.to_json
        when 'proxy'
          {
            'name' => repository_name,
            'online' => true,
            'storage' => {
              'blobStoreName' => repository_config.fetch('storage_blob_store_name', 'default'),
              'strictContentTypeValidation' => false,
            },
            'proxy' => {
              'remoteUrl' => repository_config['remote_url'],
              'contentMaxAge' => 1440,
              'metadataMaxAge' => 1440,
            },
            'negativeCache' => {
              'enabled' => true,
              'timeToLive' => 1440,
            },
            'httpClient' => {
              'blocked' => false,
              'autoBlock' => true,
              'connection' => {
                'retries' => 0,
                # 'userAgentSuffix' => 'string',
                'timeout' => 60,
                'enableCircularRedirects' => false,
                'enableCookies' => false,
                'useTrustStore' => false,
              },
            },
          }.to_json
        end
      end

      def self.repository_create_raw_payload(repository_name, repository_config)
        case repository_config['type']
        when 'hosted'
          {
            'name' => repository_name,
            'online' => true,
            'storage' => {
              'blobStoreName' => repository_config.fetch('storage_blob_store_name', 'default'),
              'strictContentTypeValidation' => true,
              'writePolicy' => 'allow',
            },
            'cleanup' => {
              'policyNames' => [],
            },
          }.to_json
        when 'proxy'
          {
            'name' => repository_name,
            'online' => true,
            'storage' => {
              'blobStoreName' => repository_config.fetch('storage_blob_store_name', 'default'),
              'strictContentTypeValidation' => false,
            },
            'proxy' => {
              'remoteUrl' => repository_config['remote_url'],
              'contentMaxAge' => 1440,
              'metadataMaxAge' => 1440,
            },
            'negativeCache' => {
              'enabled' => true,
              'timeToLive' => 1440,
            },
            'httpClient' => {
              'blocked' => false,
              'autoBlock' => true,
              'connection' => {
                'retries' => 0,
                # 'userAgentSuffix' => 'string',
                'timeout' => 60,
                'enableCircularRedirects' => false,
                'enableCookies' => false,
                'useTrustStore' => false,
              },
            },
          }.to_json
        end
      end

      # curl -u admin:admin123 -X POST 'http://localhost:8081/service/rest/v1/repositories/raw/hosted' \
      #                                 -H 'Content-Type: application/json' \
      #  -d @repo_config.json
      def self.repository_create(node, repository_name, repository_config)
        repository_format = repository_config['format']
        repository_type = repository_config['type']
        uri = URI.parse("http://localhost:8081/service/rest/v1/repositories/#{repository_format}/#{repository_type}")

        case repository_config['format']
        when 'apt'
          payload = repository_create_apt_payload(repository_name, repository_config)
        when 'docker'
          payload = repository_create_docker_payload(repository_name, repository_config)
        when 'npm'
          payload = repository_create_npm_payload(repository_name, repository_config)
        when 'pypi'
          payload = repository_create_pypi_payload(repository_name, repository_config)
        when 'raw'
          payload = repository_create_raw_payload(repository_name, repository_config)
        end

        http = Net::HTTP.new(uri.host, uri.port)

        request = Net::HTTP::Post.new(uri.request_uri, { 'Content-Type' => 'application/json' })
        request.basic_auth(admin_username(node), admin_password(node))
        request.body = payload

        response = http.request(request)

        puts "MISCHA: PUT response code: #{response.code}"
        puts "MISCHA: PUT response body: #{response.body}"
      end

      def self.repository_delete(node, repository_name)
        uri = URI.parse("http://localhost:8081/service/rest/v1/repositories/#{repository_name}")
        http = Net::HTTP.new(uri.hostname, uri.port)

        request = Net::HTTP::Delete.new(uri)
        request.basic_auth(admin_username(node), admin_password(node))

        response = http.request(request)

        puts "MISCHA: DELETE response code: #{response.code}"
        puts "MISCHA: DELETE response body: #{response.body}"
      end

      # curl -ifu admin:Superseekret63 \
      #   -X GET 'http://127.0.0.1:8081/service/rest/v1/blobstores'
      def self.blobstores_list(node)
        uri = URI.parse('http://localhost:8081/service/rest/v1/blobstores')
        request = Net::HTTP::Get.new(uri)
        request.basic_auth(admin_username(node), admin_password(node))
        request['Accept'] = 'application/json'

        response = Net::HTTP.start(uri.hostname, uri.port) do |http|
          http.request(request)
        end

        if response.code.to_i == 200
          blobstores = JSON.parse(response.body)
          Chef::Log.info("Blobstores: #{blobstores}")
          # You can process the blobstores as needed here
        else
          Chef::Log.error("Failed to get blobstores: #{response.message}")
        end
        blobstores
      end

      def self.blobstore_create_file_payload(blobstore_name, blobstore_config)
        payload = {
          'name' => blobstore_name,
          'path' => blobstore_config['path'],
        }

        payload.to_json
      end

      def self.blobstore_create_s3_payload(blobstore_name, blobstore_config)
        payload = {
          'name' => blobstore_name,
          'bucketConfiguration' => {
            'bucket' => {
              'region' => blobstore_config['bucket_region'],
              'name' => blobstore_config['bucket_name'],
              'prefix' => '',
              'expiration' => 3,
            },
            'advancedBucketConnection' => {
              'endpoint' => '',
              'forcePathStyle' => false,
            },
          },
        }

        payload.to_json
      end

      # curl -u admin:admin123 -X POST 'http://localhost:8081/service/rest/v1/repositories/raw/hosted' \
      #                                 -H 'Content-Type: application/json' \
      #  -d @repo_config.json
      def self.blobstore_create(node, blobstore_name, blobstore_config)
        blobstore_type = blobstore_config['type']
        uri = URI.parse("http://localhost:8081/service/rest/v1/blobstores/#{blobstore_type}")

        case blobstore_config['type']
        when 'file'
          payload = blobstore_create_file_payload(blobstore_name, blobstore_config)
        when 's3'
          payload = blobstore_create_s3_payload(blobstore_name, blobstore_config)
        end

        http = Net::HTTP.new(uri.host, uri.port)

        request = Net::HTTP::Post.new(uri.request_uri, { 'Content-Type' => 'application/json' })
        request.basic_auth(admin_username(node), admin_password(node))
        request.body = payload

        response = http.request(request)

        puts "MISCHA: PUT response code: #{response.code}"
        puts "MISCHA: PUT response body: #{response.body}"
      end

      def self.blobstore_delete(node, blobstore_name)
        uri = URI.parse("http://localhost:8081/service/rest/v1/blobstores/#{blobstore_name}")
        http = Net::HTTP.new(uri.hostname, uri.port)

        request = Net::HTTP::Delete.new(uri)
        request.basic_auth(admin_username(node), admin_password(node))

        response = http.request(request)

        puts "MISCHA: DELETE response code: #{response.code}"
        puts "MISCHA: DELETE response body: #{response.body}"
      end

      def repository_action(action, node, repository_name, repository_config)
        # repository_name = repository_config['name'] || key
        repository_format = repository_config['format']
        repository_type = repository_config['type']
        server_url = 'http://localhost:8081'
        user_name = Boxcutter::Sonatype::Helpers.admin_username(node)
        password = Boxcutter::Sonatype::Helpers.admin_password(node)

        # action = :create
        # action = :update if current_repository_names.include?(repository_name)
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

      def repository_create(node, repository_name, repository_config)
        repository_action(:create, node, repository_name, repository_config)
      end

      def repository_update(node, repository_name, repository_config)
        repository_action(:update, node, repository_name, repository_config)
      end
    end
  end
end
