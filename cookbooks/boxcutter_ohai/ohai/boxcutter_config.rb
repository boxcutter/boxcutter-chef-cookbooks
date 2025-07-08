# https://docs.chef.io/ohai_custom/

Ohai.plugin(:BoxcutterConfig) do
  provides 'boxcutter_config'
  depends 'hostname'

  collect_data do
    Ohai::Log.info('Entering boxcutter_config ohai plugin')

    data = Mash.new

    case hostname
    when /^robot/
      data['tier'] = 'robot'
      puts 'MISCHA: Doing the robot!!!'
    end

    config_filename = '/etc/boxcutter-config.json'
    if ::File.exist?(config_filename)
      begin
        data.merge!(JSON.parse(::File.read(config_filename)))
      rescue StandardError
        Ohai::Log.warn("Invalid #{config_filename}")
      end
    end

    Ohai::Log.info('Leaving boxcutter_config ohai plugin')

    boxcutter_config data
  end
end
