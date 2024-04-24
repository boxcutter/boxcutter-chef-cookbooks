require 'chef/http'
require 'json'
require 'uri'

unified_mode true

property :hostname, String,
         description: 'Hostname to use instead of the auto-generating the machine name from the OS hostname'
property :tailnet, String,
         description: 'Organization name found on the General Settings page of the Tailscale admin console'
property :api_base_url, String, default: 'https://api.tailscale.com',
         description: 'The base URL for the Tailscale API'
property :ephemeral, [true, false], default: true,
         description: 'Whether or not devices will be automatically removed after going offline'
property :tags, [String, Array], default: [], coerce: lambda { |v|
  # Coerce the input into an array if it's a string
  v.is_a?(String) ? [v] : v
}
# Having a timeout is not the default, but we need to set one in case of an expired/bad
# auth key, as otherwise `tailscale up` hangs forever
# https://github.com/tailscale/tailscale/issues/938
property :timeout, String, default: '60s'
property :use_tailscale_dns, [true, false], default: false
property :shields_up, [true, false], default: true

class Helpers
  extend ::Boxcutter::Tailscale::Helpers
end

load_current_value do |new_resource|
  begin
    status = Helpers.tailscale_status
    Chef::Log.debug("boxcutter_tailscale[load_current_value]: tailscale status output #{status}")
    # Description of the fields:
    # https://github.com/tailscale/tailscale/blob/main/ipn/ipnstate/ipnstate.go
    if status['BackendState'] != 'Running'
      Chef::Log.debug("boxcutter_tailscale[load_current_value]: tailscale backend not running.")
      current_value_does_not_exist!
    end

    if status['Self'].key?('Tags')
      # tags are in the form `['tag:chef', 'tag:chef-ephemeral']`, strip off
      # the "tag:" prefix from each string to compare
      tags = status['Self']['Tags']
      clean_tags = tags.map { |tag| tag.gsub("tag:", "") }
      tags clean_tags
    end
    hostname status['Self']['HostName'] unless new_resource.hostname.nil?

    prefs = Helpers.tailscale_debug_prefs
    Chef::Log.debug("boxcutter_tailscale[load_current_value]: prefs=#{prefs}")
    # Description of the fields:
    # https://github.com/tailscale/tailscale/blob/main/ipn/prefs.go
    shields_up prefs['ShieldsUp']
    use_tailscale_dns prefs['CorpDNS']
  rescue Mixlib::ShellOut::ShellCommandFailed => e
    current_value_does_not_exist!
  rescue JSON::ParserError => e
    current_value_does_not_exist!
  end
end

action :manage do
  converge_if_changed do
    Chef::Log.debug('boxcutter_tailscale: needs_tailscale_up? == true')
    if node.run_state.key?('boxcutter_tailscale') && node.run_state['boxcutter_tailscale'].key?('oauth_client_id') && node.run_state['boxcutter_tailscale'].key?('oauth_client_secret') \
       || node['boxcutter_tailscale']['oauth_client_id'] && node['boxcutter_tailscale']['oauth_client_secret']
      api_key = get_oauth_token(new_resource.api_base_url, oauth_client_id, oauth_client_secret)
      auth_key = create_auth_key(new_resource.api_base_url, new_resource.tailnet, api_key, new_resource.ephemeral,
                                 new_resource.tags)
      shell_out!(tailscale_up_cmd(auth_key))
    elsif node.run_state.key?('boxcutter_tailscale') && node.run_state['boxcutter_tailscale'].key?('auth_keys') \
          || node['boxcutter_tailscale']['auth_key']
      shell_out!(tailscale_up_cmd(auth_key))
    else
      fail 'boxcutter_tailscale: needs tailscale up but oauth_client_id/oauth_client_secret or auth_key not found'
    end
  end
end

action_class do
  def needs_tailscale_up?
    # Description of the fields:
    # https://github.com/tailscale/tailscale/blob/main/ipn/ipnstate/ipnstate.go
    result = shell_out('tailscale status --peers=false --json')
    status = JSON.parse(result.stdout)
    Chef::Log.debug("boxcutter_tailscale: tailscale status output #{status}")
    return true if status['BackendState'] == 'NeedsLogin'

    if status['BackendState'] == 'Running'
      return true if status['Self']['Online'] == false
      if node['boxcutter_tailscale']['hostname'].nil?
        return true if status['Self']['HostName'] != node['hostname']
      elsif status['Self']['HostName'] != node['boxcutter_tailscale']['hostname']
        return true
      end
    end
    false
  end

  def tailscale_up_cmd(auth_key)
    cmd = ['tailscale up']
    cmd << %{--auth-key #{auth_key}}
    use_tailscale_dns = new_resource.use_tailscale_dns ? '' : '=false'
    cmd << ["--accept-dns#{use_tailscale_dns}"]
    shields_up = new_resource.shields_up ? '' : '=false'
    cmd << ["--shields-up#{shields_up}"]
    cmd << %{--timeout #{new_resource.timeout}}
    formatted_tags = new_resource.tags.map { |tag| "tag:#{tag}" }.join(',')
    unless formatted_tags.empty?
      cmd << %{--advertise-tags=#{formatted_tags}}
    end
    hostname = new_resource.hostname ? "--hostname #{new_resource.hostname}" : ''
    cmd << [hostname.to_s]
    cmd.join(' ')
  end

  def run_state_or_attribute(attribute)
    if node.run_state.key?('boxcutter_tailscale') && node.run_state['boxcutter_tailscale'].key?(attribute)
      node.run_state['boxcutter_tailscale'][attribute]
    else
      node['boxcutter_tailscale'][attribute]
    end
  end

  def oauth_client_id
    run_state_or_attribute('oauth_client_id')
  end

  def oauth_client_secret
    run_state_or_attribute('oauth_client_secret')
  end

  def auth_key
    run_state_or_attribute('auth_key')
  end

  def get_oauth_token(api_base_url, oauth_client_id, oauth_client_secret)
    # https://github.com/tailscale/tailscale/blob/main/api.md
    # curl -d "client_id=${OAUTH_CLIENT_ID}" -d "client_secret=${OAUTH_CLIENT_SECRET}" \
    #  "https://api.tailscale.com/api/v2/oauth/token"
    # curl --data "client_id=${OAUTH_CLIENT_ID}" --data "client_secret=${OAUTH_CLIENT_SECRET}" \
    #  "https://api.tailscale.com/api/v2/oauth/token"

    uri = URI.parse(api_base_url)
    # Normally https://api.tailscale.com
    http = Chef::HTTP.new("#{uri.scheme}://#{uri.host}:#{uri.port}")
    path = ::File.join(uri.path, '/api/v2/oauth/token')
    data = URI.encode_www_form(
      'client_id' => oauth_client_id,
      'client_secret' => oauth_client_secret,
    )

    headers = {
      'Content-Type' => 'application/x-www-form-urlencoded',
    }

    response = http.request('POST', path, headers, data)
    response_data = JSON.parse(response)
    response_data['access_token']
  end

  # https://github.com/tailscale/tailscale/blob/main/api.md#create-auth-key
  def create_auth_key(api_base_url, tailnet, api_key, ephemeral, tags)
    uri = URI.parse(api_base_url)
    base_path = "#{uri.scheme}://#{uri.host}:#{uri.port}"
    if tailnet.nil?
      full_path = ::File.join(base_path, '/api/v2/tailnet/-/keys')
    else
      full_path = ::File.join(base_path, "/api/v2/tailnet/#{tailnet}/keys")
    end

    # url = "https://api.tailscale.com/api/v2/tailnet/#{tailnet}/keys"
    formatted_tags = tags.map { |tag| "tag:#{tag}" }.join(', ')
    hostname = new_resource.hostname.nil? ? node['hostname'] : new_resource.hostname

    data = {
      capabilities: {
        devices: {
          create: {
            reusable: false,
            ephemeral: ephemeral,
            preauthorized: true,
            tags: [formatted_tags],
          },
        },
      },
      expirySeconds: 86400,
      description: "Chef Tailscale auth key to provision #{hostname}",
    }

    json_data = data.to_json
    http_client = Chef::HTTP.new(full_path, headers: {
                                   'Authorization' => 'Basic ' + Base64.strict_encode64("#{api_key}:").chomp,
      'Content-Type' => 'application/json',
                                 })
    response = http_client.post('', json_data)
    response_data = JSON.parse(response)
    response_data['key']
  end
end
