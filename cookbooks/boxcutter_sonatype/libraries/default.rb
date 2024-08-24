module Boxcutter
  class Sonatype
    module Helpers
      def self.run_state_or_attribute(node, attribute)
        if node.run_state.key?('boxcutter_sonatype') && node.run_state['boxcutter_sonatype']['nexus_repository'] && node.run_state['boxcutter_sonatype']['nexus_repository'].key?(attribute)
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
          {
            'name' => repository_name,
            'online' => true,
            'storage' => {
              'blobStoreName' => 'default',
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
            'apt' => {
              'distribution' => repository_config['distribution'],
              'flat' => repository_config['flat'],
            },
          }.to_json
        end
      end

      def self.repository_create_docker_payload(repository_name, repository_config)
        case repository_config['type']
        when 'proxy'
          {
            'name' => repository_name,
            'online' => true,
            'storage' => {
              'blobStoreName' => 'default',
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

      def self.repository_create_raw_payload(repository_name, repository_config)
        case repository_config['type']
        when 'hosted'
          {
            'name' => repository_name,
            'online' => true,
            'storage' => {
              'blobStoreName' => 'default',
              'strictContentTypeValidation' => true,
              'writePolicy' => 'allow',
            },
            'cleanup' => {
              'policyNames' => [],
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
    end
  end
end
