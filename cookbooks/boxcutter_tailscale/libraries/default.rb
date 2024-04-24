require 'chef/mixin/shell_out'

module Boxcutter
  class Tailscale
    module Helpers
      include Chef::Mixin::ShellOut

      def tailscale_status
        cmd = Mixlib::ShellOut.new('/usr/bin/tailscale status --peers=false --json')
        cmd.run_command
        cmd.error!

        # Description of the fields:
        # https://github.com/tailscale/tailscale/blob/main/ipn/ipnstate/ipnstate.go
        JSON.parse(cmd.stdout)
      end

      def tailscale_debug_prefs
        cmd = Mixlib::ShellOut.new('/usr/bin/tailscale debug prefs')
        cmd.run_command
        cmd.error!

        # Description of the fields:
        # https://github.com/tailscale/tailscale/blob/main/ipn/prefs.go
        JSON.parse(cmd.stdout)
      end
    end
  end
end
