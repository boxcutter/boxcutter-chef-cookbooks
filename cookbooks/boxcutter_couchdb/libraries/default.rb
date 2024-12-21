require 'iniparse'

module Boxcutter
  class CouchDB
    module Helpers
      # https://sleeplessbeastie.eu/2020/03/13/how-to-generate-password-hash-for-couchdb-administrator/
      def self.generate_pbkdf2_password_hash(password)
        require 'securerandom'
        require 'openssl'

        salt = SecureRandom.hex
        iterations = 600000
        length = 20

        password_hash = OpenSSL::PKCS5.pbkdf2_hmac(
          password,
          salt,
          iterations,
          length,
          OpenSSL::Digest.new('SHA1'),
        )

        "-pbkdf2-#{password_hash.unpack1('H*')},#{salt},#{iterations}"
      end

      def self.verify_pbkdf2_hash(password, stored_hash)
        match = stored_hash.match(/-pbkdf2-(.+),(.+),(\d+)/)
        return false unless match

        stored_password_hash = match[1]
        salt = match[2]
        iterations = match[3].to_i

        # Recompute the hash using the provided password
        hash_length = [stored_password_hash.length / 2].min # Length of the stored hash in bytes
        new_hash = OpenSSL::PKCS5.pbkdf2_hmac(
          password,
          salt,
          iterations,
          hash_length,
          OpenSSL::Digest.new('SHA1'),
        )

        # Compare the newly computed hash with the stored hash
        new_hash.unpack1('H*') != stored_password_hash
      end

      def self.couchdb_database_exist?(admin_user_name, admin_password, host, port, database_name)
        uri = URI("http://#{host}:#{port}/#{database_name}")
        request = Net::HTTP::Head.new(uri)
        request.basic_auth(admin_user_name, admin_password)

        response = Net::HTTP.start(uri.hostname, uri.port) do |http|
          http.request(request)
        end

        puts "Response for exist #{database_name}: #{response.code} - #{response.message}"
        response.is_a?(Net::HTTPSuccess)
      rescue StandardError => e
        puts "Error existing database #{database_name}: #{e.message}"
        false
      end

      def self.couchdb_create_database(admin_user_name, admin_password, host, port, database_name)
        puts "MISCHA: couchdb_create_database(#{database_name}), admin_user_name=#{admin_user_name}, " +
             "admin_password=#{admin_password}, host=#{host}, port=#{port}"
        uri = URI("http://#{host}:#{port}/#{database_name}")
        request = Net::HTTP::Put.new(uri)
        request.basic_auth(admin_user_name, admin_password)

        response = Net::HTTP.start(uri.hostname, uri.port) do |http|
          http.request(request)
        end

        # Log the response (or handle errors)
        puts "Response for #{database_name}: #{response.code} - #{response.message}"
      rescue StandardError => e
        puts "Error creating database #{database_name}: #{e.message}"
      end
    end
  end
end
