module Boxcutter
  class PostgreSQL
    module Helpers
      def self.gem_installed?(gem_name)
        !Gem::Specification.find_by_name(gem_name).nil?
      rescue Gem::LoadError
        false
      end

      def install_pg_gem
        build_essential 'Install compilers'

        postgresql_devel_pkg_name = case node['platform_family']
                                    when 'rhel'
                                      'postgresql-devel'
                                    when 'debian'
                                      'libpq-dev'
                                    when 'amazon'
                                      'libpq-devel'
                                    end
        package postgresql_devel_pkg_name

        pg_gem_build_options = case node['platform_family']
                               when 'debian'
                                 '-- --with-pg-include=/usr/include/postgresql --with-pg-lib=/usr/include/postgresql'
                               else
                                 fail "Unsupported platform family #{node['platform_family']}"
                               end

        chef_gem 'pg' do
          options pg_gem_build_options
          version '~> 1.5'
        end
      end

      def self.pg_client
        if @pg_client
          begin
            @pg_client.exec('SELECT 1') # very lightweight ping
            return @pg_client
          rescue PG::Error => e
            Chef::Log.warn("PG client was disconnected (#{e.message}), reconnecting...") if defined?(Chef::Log)
            @pg_client = nil
          end
        end

        puts 'MISCHA: pg_client - no existing connection, so creating a new one'

        # No existing connection or it was dead, so create a fresh one
        require 'pg'

        original_euid = Process.euid
        Process::UID.eid = Process::UID.from_name('postgres')

        client = nil
        begin
          connection_params = { port: 5432, user: 'postgres' }
          client = ::PG::Connection.new(**connection_params)
        ensure
          if Process.euid != original_euid
            Process::UID.eid = original_euid
          end
        end

        # By default the pg gem sends everything as plain strings.
        # PG::BasicTypeMapForQueries sets up standard automated type
        # conversions when you send ruby objects as query parameters,
        # and automatically encodes them into the right PostgrSQL format.
        client.type_map_for_queries = PG::BasicTypeMapForQueries.new(client)
        Chef::Log.debug('PG client (re)created successfully') if defined?(Chef::Log)
        @pg_client = client
      end

      def self.execute_sql(query, max_one_result: false)
        Chef::Log.debug("Executing query: #{query}")
        puts "MISCHA: execute_sql_query=#{query}"
        result = pg_client.exec(query).to_a

        Chef::Log.debug("Got result: #{result}")
        puts "MISCHA: got result=#{result}"
        return if result.empty?

        fail "Expected a single result, got #{result.count}" unless result.one? || !max_one_result

        result
      end

      def self.execute_sql_params(query, params, max_one_result: false)
        Chef::Log.debug("Executing query: #{query} with params: #{params}")
        puts "MISCHA: execute_sql_params query=#{query}, params=#{params}"
        result = pg_client.exec_params(query, params).to_a

        Chef::Log.debug("Got result: #{result}")
        puts "MISCHA: got result=#{result}"
        return if result.empty?

        fail "Expected a single result, got #{result.count}" unless result.one? || !max_one_result

        result
      end

      def self.nil_or_empty?(obj)
        obj.nil? || (obj.respond_to?(:empty?) && obj.empty?)
      end

      def self.map_pg_values!(hash)
        fail ArgumentError unless hash.is_a?(Hash)

        hash.transform_values! do |v|
          case v
          when 't'
            true
          when 'f'
            false
          else
            v
          end
        end
      end

      #
      # Role
      #

      def self.role_exist?(role_name)
        sql = 'SELECT rolname FROM pg_roles WHERE rolname=$1'
        result = execute_sql_params(sql, [role_name], max_one_result: true)
        !nil_or_empty?(result)
      end

      def self.select_role(role_name)
        sql = 'SELECT rolname FROM pg_roles WHERE rolname=$1'
        result = execute_sql_params(sql, [role_name])

        return if result.to_a.empty?

        query_result = result.to_a.pop
        map_pg_values!(query_result)

        query_result
      end

      def self.create_role_sql_request(new_resource)
        sql = []

        sql.push("CREATE ROLE \"#{new_resource.role_name}\" WITH")

        if new_resource.encrypted_password
          sql.push("ENCRYPTED PASSWORD '#{new_resource.encrypted_password}'")
        elsif new_resource.plain_text_password
          sql.push("PASSWORD '#{new_resource.plain_text_password}'")
        else
          sql.push('PASSWORD NULL')
        end

        "#{sql.join(' ').strip};"
      end

      def self.create_role(new_resource)
        execute_sql(create_role_sql_request(new_resource))
      end

      def self.drop_role(new_resource)
        execute_sql("DROP ROLE \"#{new_resource.user_name}\"")
      end
    end
  end
end
