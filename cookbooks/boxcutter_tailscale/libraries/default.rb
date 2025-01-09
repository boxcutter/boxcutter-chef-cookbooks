module Boxcutter
  class Tailscale
    module Helpers
      # Use extend instead of include, so we can use the "shell_out" mixin. To
      # use a mixin, you either need to include it into the Chef::Recipe class,
      # or use an extend (instead of include).
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
