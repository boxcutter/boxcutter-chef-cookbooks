require 'iniparse'

module Boxcutter
  class Grafana
    module Helpers
      def self.grafana_config_to_ini(config)
        IniParse.gen do |doc|
          config.each do |config_section, options|
            doc.section(config_section) do |section|
              options.each do |key, value|
                section.option(key, value)
              end
            end
          end
        end
      end
    end
  end
end
