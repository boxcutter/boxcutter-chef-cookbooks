require 'chef/mixin/shell_out'

module Boxcutter
  class Tailscale
    module Helpers
      include Chef::Mixin::ShellOut

      def load_config
        result = shell_out!('/usr/bin/tailscale debug prefs')
        JSON.parse(result.stdout)
      end
    end
  end
end
