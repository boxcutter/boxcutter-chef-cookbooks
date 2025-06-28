require 'fileutils'

module Boxcutter
  class Ohai
    module Helpers
      def self.firstboot_handler(run_status)
        # We could be called when the run fails, so we might not have
        # node defined, but we can get it from run_status
        node = run_status.node
        puts 'MISCHA: in firstboot_handler'

        if node['fb_init']['firstboot_os']
          if ::File.exist?('/root/firstboot_os')
            puts 'MISCHA: removing /root/firstboot_os'
            ::File.delete('/root/firstboot_os')
          end
        elsif node['fb_init']['firstboot_tier']
          if ::File.exist?('/root/firstboot_tier')
            puts 'MISCHA: removing /root/firstboot_tier'
            ::File.delete('/root/firstboot_tier')
          end
        end
      end
    end
  end
end
