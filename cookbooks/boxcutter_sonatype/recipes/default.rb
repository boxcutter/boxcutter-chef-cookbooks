#
# Cookbook:: boxcutter_sonatype
# Recipe:: default
#
# Copyright:: 2024-present, Taylor.dev, LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

admin_password = node['boxcutter_sonatype']['nexus_repository']['admin_password']
if node.run_state.key?('boxcutter_sonatype') \
   && node.run_state['boxcutter_sonatype'].key?('nexus_repository') \
   && node.run_state['boxcutter_sonatype']['nexus_repository'].key?('admin_password')
  admin_password = node.run_state['boxcutter_sonatype']['nexus_repository']['admin_password']
end

node.default['fb_iptables']['filter']['INPUT']['rules']['nexus'] = {
  'rules' => [
    '-p tcp --dport 8081 -j ACCEPT',
    '-p tcp --dport 8082 -j ACCEPT',
    '-p tcp --dport 10080 -j ACCEPT',
    '-p tcp --dport 10443 -j ACCEPT',
  ],
}

# We used to make the home for the 'nexus' user to be /opt/sonatype/nexus,
# but recent versions of Nexus require things like javaPrefs
# runuser -u nexus -- /bin/bash
# cd /opt/sonatype/nexus/bin
# ./nexus run
if defined?(FB::Users)
  FB::Users.initialize_group(node, 'nexus')
  node.default['fb_users']['users']['nexus'] = {
    'home' => '/var/lib/nexus',
    'gid' => 'nexus',
    'shell' => '/usr/sbin/nologin',
    'action' => :add,
  }
end

boxcutter_sonatype_nexus_repository_tarball 'install' do
  version lazy { node['boxcutter_sonatype']['nexus_repository']['version'] }
  url lazy { node['boxcutter_sonatype']['nexus_repository']['url'] }
  checksum lazy { node['boxcutter_sonatype']['nexus_repository']['checksum'] }
end

directory 'nexus data dir' do
  path lazy { node['boxcutter_sonatype']['nexus_repository']['nexus_data_dir'] }
  owner 'nexus'
  group 'nexus'
  mode '0755'
  recursive true
end

directory 'nexus data dir etc' do
  path lazy { ::File.join(node['boxcutter_sonatype']['nexus_repository']['nexus_data_dir'], 'etc') }
  owner 'nexus'
  group 'nexus'
  mode '0755'
  recursive true
end

directory 'nexus data dir log' do
  path lazy { ::File.join(node['boxcutter_sonatype']['nexus_repository']['nexus_data_dir'], 'log') }
  owner 'nexus'
  group 'nexus'
  mode '0755'
  recursive true
end

template 'nexus properties' do
  path lazy { ::File.join(node['boxcutter_sonatype']['nexus_repository']['nexus_data_dir'], 'etc', 'nexus.properties') }
  source 'nexus.properties.erb'
  owner 'nexus'
  group 'nexus'
  mode '0644'
end

execute 'nexus reload systemd' do
  command '/bin/systemctl daemon-reload'
  action :nothing
end

template '/etc/systemd/system/nexus.service' do
  source 'nexus.service.erb'
  mode '0644'
  owner node.root_user
  group node.root_group
  notifies :run, 'execute[nexus reload systemd]', :immediately
end

service 'nexus' do
  action [:enable, :start]
end

whyrun_safe_ruby_block 'wait for nexus http' do
  block do
    require 'net/http'
    require 'uri'
    require 'timeout'

    uri = URI('http://127.0.0.1:8081/')

    Timeout.timeout(300) do
      loop do
        begin
          res = Net::HTTP.start(
            uri.host,
            uri.port,
            :open_timeout => 5,
            :read_timeout => 5,
          ) { |http| http.get(uri.request_uri) }

          if res.is_a?(Net::HTTPSuccess)
            Chef::Log.info('Nexus HTTP endpoint is reachable.')
            break
          end

          Chef::Log.info("Nexus returned HTTP #{res.code}; retrying...")
        rescue Errno::ECONNREFUSED, Errno::ECONNRESET,
               Errno::EHOSTUNREACH, Errno::ENETUNREACH,
               Errno::ETIMEDOUT,
               Net::OpenTimeout, Net::ReadTimeout,
               EOFError, SocketError => e
          Chef::Log.info("Nexus not ready yet (#{e}); retrying...")
        end

        sleep 5
      end
    end
  rescue Timeout::Error
    raise 'Timed out waiting for Nexus HTTP endpoint'
  end
end

whyrun_safe_ruby_block 'bootstrap nexus admin' do
  block do
    require 'net/http'
    require 'uri'
    require 'json'
    require 'timeout'

    nexus_url = 'http://127.0.0.1:8081'
    eula_uri        = URI("#{nexus_url}/service/rest/v1/system/eula")
    change_pw_uri   = URI("#{nexus_url}/service/rest/v1/security/users/admin/change-password")
    anonymous_uri   = URI("#{nexus_url}/service/rest/v1/security/anonymous")
    realms_uri      = URI("#{nexus_url}/service/rest/v1/security/realms/active") # simple auth probe

    desired_anonymous = true

    nexus_data_dir = node['boxcutter_sonatype']['nexus_repository']['nexus_data_dir'] # /var/lib/nexus/nexus-data
    admin_pw_candidates = [
      ::File.join(nexus_data_dir, 'admin.password'),
    ]

    http_request = lambda do |uri, req, attempts: 60, delay: 5|
      last_error = nil

      attempts.times do |i|
        return Net::HTTP.start(uri.host, uri.port,
                               :open_timeout => 5,
                               :read_timeout => 20) { |h| h.request(req) }
      rescue Errno::ECONNREFUSED, Errno::ECONNRESET, Errno::EHOSTUNREACH, Errno::ENETUNREACH,
             Errno::ETIMEDOUT, Net::OpenTimeout, Net::ReadTimeout, EOFError, SocketError => err
        last_error = err
        if i == attempts - 1
          raise "Nexus: unable to connect to #{uri} after #{attempts} attempts: #{err.class}: #{err.message}"
        end
        Chef::Log.info("Nexus: #{uri} not reachable yet (#{e.class}: #{e.message}); retrying in #{delay}s...")
        sleep delay
      end

      fail last_error # should never reach
    end

    # Auth probe: returns true if password works
    auth_ok = lambda do |password|
      req = Net::HTTP::Get.new(realms_uri)
      req.basic_auth('admin', password)
      res = http_request.call(realms_uri, req)
      res.code.to_i == 200
    end

    # One-time password change using known current password
    change_admin_password = lambda do |old_pw, new_pw|
      req = Net::HTTP::Put.new(change_pw_uri)
      req.basic_auth('admin', old_pw)
      req['Content-Type'] = 'text/plain'
      req.body = new_pw
      res = http_request.call(change_pw_uri, req)
      unless [200, 204].include?(res.code.to_i)
        fail "Nexus: failed to change admin password: HTTP #{res.code} #{res.message} #{res.body}"
      end
    end

    ensure_anonymous_setting = lambda do |password, desired_enabled|
      get_req = Net::HTTP::Get.new(anonymous_uri)
      get_req.basic_auth('admin', password)
      get_res = http_request.call(anonymous_uri, get_req)

      return if get_res.code.to_i == 404

      unless get_res.code.to_i == 200
        fail "Nexus: GET /security/anonymous failed: HTTP #{get_res.code} #{get_res.message} #{get_res.body}"
      end

      current = JSON.parse(get_res.body)

      # Build desired payload from what Nexus reports (keeps required fields like realmName/userId)
      desired = current.merge('enabled' => desired_enabled)

      Chef::Log.info("Nexus: forcing anonymous.enabled=#{desired_enabled} (was #{current['enabled'].inspect})")

      put_req = Net::HTTP::Put.new(anonymous_uri)
      put_req.basic_auth('admin', password)
      put_req['Content-Type'] = 'application/json'
      put_req.body = JSON.dump(desired)

      put_res = http_request.call(anonymous_uri, put_req)
      unless [200, 204].include?(put_res.code.to_i)
        fail "Nexus: failed to set anonymous=#{desired_enabled}: " \
             "HTTP #{put_res.code} #{put_res.message} #{put_res.body}"
      end

      # Re-check to confirm it actually changed
      verify_req = Net::HTTP::Get.new(anonymous_uri)
      verify_req.basic_auth('admin', password)
      verify_res = http_request.call(anonymous_uri, verify_req)

      unless verify_res.code.to_i == 200
        fail "Nexus: verify GET failed: HTTP #{verify_res.code} #{verify_res.message} #{verify_res.body}"
      end

      verify_body = JSON.parse(verify_res.body)
      unless verify_body['enabled'] == desired_enabled
        fail "Nexus: anonymous.enabled is still #{verify_body['enabled'].inspect} after PUT"
      end

      Chef::Log.info("Nexus: anonymous.enabled now #{verify_body['enabled']}.")
    end

    # Accept EULA (must GET disclaimer then POST it back with accepted=true)
    accept_eula = lambda do |password|
      # Some versions may not have this endpoint
      get_req = Net::HTTP::Get.new(eula_uri)
      get_req.basic_auth('admin', password)
      get_res = http_request.call(eula_uri, get_req)

      return if get_res.code.to_i == 404

      unless get_res.code.to_i == 200
        fail "Nexus: GET /system/eula failed: HTTP #{get_res.code} #{get_res.message} #{get_res.body}"
      end

      body = JSON.parse(get_res.body)
      if body['accepted'] == true
        Chef::Log.info('Nexus: EULA already accepted.')
        return
      end

      disclaimer = body['disclaimer'].to_s
      fail 'Nexus: EULA disclaimer missing/empty' if disclaimer.empty?

      post_req = Net::HTTP::Post.new(eula_uri)
      post_req.basic_auth('admin', password)
      post_req['Content-Type'] = 'application/json'
      post_req.body = JSON.dump({ 'accepted' => true, 'disclaimer' => disclaimer })

      post_res = http_request.call(eula_uri, post_req)
      unless [200, 204].include?(post_res.code.to_i)
        fail "Nexus: POST /system/eula failed: HTTP #{post_res.code} #{post_res.message} #{post_res.body}"
      end

      Chef::Log.info('Nexus: EULA accepted.')
    end

    Timeout.timeout(300) do
      # --- Step 1: ensure managed admin password works ---
      unless auth_ok.call(admin_password)
        # managed password doesn't work; bootstrap using admin.password if available
        pw_file = admin_pw_candidates.find { |p| ::File.exist?(p) }
        if pw_file.nil?
          fail 'Nexus: managed admin password rejected and no bootstrap ' \
               "admin.password found in: #{admin_pw_candidates.join(', ')}"
        end

        bootstrap_pw = ::File.read(pw_file).strip
        fail "Nexus: bootstrap password file empty: #{pw_file}" if bootstrap_pw.empty?

        # Always try to apply anonymous setting with bootstrap password (even if it may fail)
        begin
          ensure_anonymous_setting.call(bootstrap_pw, desired_anonymous)
        rescue Errno::ECONNREFUSED, Errno::ECONNRESET, Errno::EHOSTUNREACH,
               Errno::ENETUNREACH, Errno::ETIMEDOUT,
               Net::OpenTimeout, Net::ReadTimeout,
               EOFError, SocketError,
               JSON::ParserError
          Chef::Log.info('Nexus: could not set anonymous with bootstrap password; continuing bootstrap...')
        rescue StandardError => err
          Chef::Log.warn('Nexus: unexpected error setting anonymous with bootstrap ' \
                         "password (#{err.class}: #{err.message}); continuing...")
        end

        # Now change admin password to managed password
        Chef::Log.info("Nexus: setting managed admin password using #{pw_file}...")
        change_admin_password.call(bootstrap_pw, admin_password)

        unless auth_ok.call(admin_password)
          fail 'Nexus: admin password change appeared to succeed, but managed password still cannot authenticate'
        end
      end

      # --- Step 2: accept EULA (requires admin auth) ---
      accept_eula.call(admin_password)

      # Step 3: enforce anonymous access as configured
      ensure_anonymous_setting.call(admin_password, desired_anonymous)
    end
  end
end

boxcutter_sonatype_nexus_repository 'configure'
