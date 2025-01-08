require 'chef/mixin/shell_out'

module Boxcutter
  class Tailscale
    module Helpers
      extend Chef::Mixin::ShellOut

      def self.tailscale_status
        result = shell_out!('/usr/bin/tailscale status --peers=false --json')

        # Description of the fields:
        # https://github.com/tailscale/tailscale/blob/main/ipn/ipnstate/ipnstate.go
        JSON.parse(result.stdout)
      end

      def tailscale_debug_prefs
        result = shell_out!('/usr/bin/tailscale debug prefs')

        # Description of the fields:
        # https://github.com/tailscale/tailscale/blob/main/ipn/prefs.go
        JSON.parse(result.stdout)
      end
    end
  end
end
