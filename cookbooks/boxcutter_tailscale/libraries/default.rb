require 'chef/mixin/shell_out'

module Boxcutter
  class Tailscale
    module Helpers
      include Chef::Mixin::ShellOut

      def load_config
        begin
          result = shell_out!('/usr/bin/tailscale debug prefs')
          JSON.parse(result.stdout)
        rescue Mixlib::ShellOut::ShellCommandFailed => e
          Chef::Log.error("boxcutter_tailscale: load_config() failed to execute command: #{e.message}")
          return nil
        rescue JSON::ParserError => e
          Chef::Log.error("boxcutter_tailscale: load_config() JSON parsing failed: #{e.message}")
          return nil
        end
      end
    end
  end
end
