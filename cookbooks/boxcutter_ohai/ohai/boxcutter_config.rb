# https://docs.chef.io/ohai_custom/

Ohai.plugin(:BoxcutterConfig) do
  provides 'boxcutter_config'

  collect_data do
    Ohai::Log.info('Entering boxcutter_config ohai plugin')

    data = Mash.new

    config_filename = '/etc/boxcutter-config.json'
    if ::File.exist?(config_filename)
      begin
        data.merge!(JSON.parse(::File.read(config_filename)))
      rescue
        Ohai::Log.warn("Invalid #{config_filename}")
      end
    end

    Ohai::Log.info('Leaving boxcutter_config ohai plugin')

    boxcutter_config data
  end
end
