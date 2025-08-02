module Boxcutter
  class PostgreSQL
    module Helpers
      @pg_connection = {}

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

      def self.pg_client(new_resource)
        require 'pg'

        # if @pg_client
        #   begin
        #     @pg_client.exec('SELECT 1') # very lightweight ping
        #     return @pg_client
        #   rescue PG::Error => e
        #     Chef::Log.warn("PG client was disconnected (#{e.message}), reconnecting...") if defined?(Chef::Log)
        #     @pg_client = nil
        #   end
        # end

        key = [
          new_resource.connect_dbname,
          new_resource.connect_username,
          new_resource.connect_password,
          new_resource.connect_hostname,
          new_resource.connect_port,
          new_resource.connection_string,
        ].freeze

        puts("Got params: #{key}")

        client = @pg_connection[key]

        if client.is_a?(::PG::Connection)
          puts("MISCHA: Returning pre-existing client for #{key}")
          return client
        end

        puts 'MISCHA: pg_client - no existing connection, so creating a new one'

        # No existing connection or it was dead, so create a fresh one
        # require 'pg'

        original_euid = Process.euid
        Process::UID.eid = Process::UID.from_name('postgres')

        client = nil
        begin
          # connection_params = { port: 5432, user: 'postgres' }
          connection_params = { :host => new_resource.connect_hostname, :port => new_resource.connect_port,
:dbname => new_resource.connect_dbname, :user => new_resource.connect_username, :password => new_resource.connect_password }
          client = ::PG::Connection.new(**connection_params)
        ensure
          if Process.euid != original_euid
            Process::UID.eid = original_euid
          end
        end

        # By default the pg gem sends everything as plain strings.
        # PG::BasicTypeMapForQueries sets up standard automated type
        # conversions when you send ruby objects as query parameters,
        # and automatically encodes them into the right PostgreSQL format.
        client.type_map_for_queries = PG::BasicTypeMapForQueries.new(client)
        Chef::Log.debug('PG client (re)created successfully') if defined?(Chef::Log)
        # @pg_client = client
        @pg_connection[key] = client
      end

      def self.execute_sql(new_resource, query, max_one_result: false)
        Chef::Log.debug("Executing query: #{query}")
        puts "MISCHA: execute_sql_query=#{query}"
        result = pg_client(new_resource).exec(query).to_a

        Chef::Log.debug("Got result: #{result}")
        puts "MISCHA: got result=#{result}"
        return if result.empty?

        fail "Expected a single result, got #{result.count}" unless result.one? || !max_one_result

        result
      end

      def self.execute_sql_params(new_resource, query, params, max_one_result: false)
        Chef::Log.debug("Executing query: #{query} with params: #{params}")
        puts "MISCHA: execute_sql_params query=#{query}, params=#{params}"
        result = pg_client(new_resource).exec_params(query, params).to_a

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

      def self.role_exist?(new_resource)
        sql = 'SELECT rolname FROM pg_roles WHERE rolname=$1'
        result = execute_sql_params(new_resource, sql, [new_resource.role_name], :max_one_result => true)
        !nil_or_empty?(result)
      end

      def self.select_role(new_resource)
        sql = 'SELECT rolname FROM pg_roles WHERE rolname=$1'
        result = execute_sql_params(new_resource, sql, [new_resource.role_name])

        return if result.to_a.empty?

        query_result = result.to_a.pop
        map_pg_values!(query_result)

        query_result
      end

      def self.create_role_sql_request(new_resource)
        sql = []

        sql.push("CREATE ROLE \"#{new_resource.role_name}\" WITH")

        %i{login}.each do |perm|
          next unless new_resource.property_is_set?(perm)

          if new_resource.send(perm)
            sql.push(perm.to_s.upcase.gsub('_', ' ').to_s)
          else
            sql.push("NO#{perm.to_s.upcase.gsub('_', ' ')}")
          end
        end

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
        execute_sql(new_resource, create_role_sql_request(new_resource))
      end

      def self.drop_role(new_resource)
        execute_sql(new_resource, "DROP ROLE \"#{new_resource.user_name}\"")
      end

      def self.alter_role_password(new_resource)
        sql = []
        sql.push("ALTER ROLE \"#{new_resource.role_name}\"")

        %i{login}.each do |perm|
          next unless new_resource.property_is_set?(perm)

          if new_resource.send(perm)
            sql.push(perm.to_s.upcase.gsub('_', ' ').to_s)
          else
            sql.push("NO#{perm.to_s.upcase.gsub('_', ' ')}")
          end
        end

        if new_resource.encrypted_password
          sql.push("ENCRYPTED PASSWORD '#{new_resource.encrypted_password}'")
        elsif new_resource.plain_text_password
          sql.push("PASSWORD '#{new_resource.plain_text_password}'")
        else
          sql.push('PASSWORD NULL')
        end

        execute_sql(new_resource, "#{sql.join(' ').strip};")
      end

      #
      # Database
      #

      def self.database_exist?(new_resource)
        sql = 'SELECT * FROM pg_database WHERE datname=$1'
        params = [new_resource.database_name]
        result = execute_sql_params(new_resource, sql, params, :max_one_result => true)

        return false if result.to_a.empty?

        database = result.to_a.pop
        map_pg_values!(database)

        !nil_or_empty?(database)
      end

      def self.select_database(new_resource)
        sql = 'SELECT * FROM pg_database WHERE datname=$1'
        params = [new_resource.database_name]
        result = execute_sql_params(new_resource, sql, params, :max_one_result => true)

        return if result.to_a.empty?

        query_result = result.to_a.pop
        map_pg_values!(query_result)

        query_result
      end

      def self.create_database_sql_request(new_resource)
        sql = []
        sql.push("CREATE DATABASE \"#{new_resource.database_name}\"")

        properties = %i{
          owner
        }
        if properties.any? { |p| new_resource.property_is_set?(p) }
          sql.push('WITH')

          properties.each do |p|
            next if nil_or_empty?(new_resource.send(p))

            property_string = if p.is_a?(Integer)
                                "#{p.to_s.upcase}=#{new_resource.send(p)}"
                              else
                                "#{p.to_s.upcase}=\"#{new_resource.send(p)}\""
                              end
            sql.push(property_string)
          end
        end
        "#{sql.join(' ').strip};"
      end

      def self.create_database(new_resource)
        execute_sql(new_resource, create_database_sql_request(new_resource))
      end

      def self.alter_database(new_resource); end

      def self.alter_database_owner(new_resource)
        execute_sql(new_resource, "ALTER DATABASE #{new_resource.database_name} OWNER TO #{new_resource.owner}")
      end

      def self.drop_database(new_resource)
        sql = "DROP DATABASE #{new_resource.database_name}"
        # sql.concat(' WITH FORCE') if new_resource.force
        execute_sql(new_resource, sql)
      end

      #
      # Access Privileges
      #

      def self.schema_privilege?(new_resource)
        # not_if %(psql -d netbox -tAc "SELECT has_schema_privilege('netbox', 'public', 'CREATE');" | grep -q t)
        sql = 'SELECT has_schema_privilege($1, $2, $3)'
        params = [new_resource.role, new_resource.object, new_resource.privilege]
        puts "MISCHA: execute_sql_params query=#{sql}, params=#{params}"
        result = pg_client(new_resource).exec_params(sql, params)

        puts "MISCHA: got result=#{result.getvalue(0, 0)}"
        result.getvalue(0, 0) == 't'
      end

      def self.grant_access_privileges(new_resource)
        sql = "GRANT #{new_resource.privilege} ON #{new_resource.type} #{new_resource.object} TO #{new_resource.role}"
        execute_sql(new_resource, sql)
      end
    end
  end
end
