# This is a custom Chef handler that can be used to track where attributes
# have been set.
# To use, set the log level to :debug or :trace.
# If you are using "human reable" in your chefctl-config.rb, it will
# force "-l fatal -F doc", so in that case, you'll need to set the log
# level explicitly rather than using the '-d' convenience method for
# chefctl:
#
#  chefctl -ivd -- --log_level debug
#  chefctl -ivd -- --log_level trace
Chef.event_handler do
  on :attribute_changed do |precedence, key, value|
    # Skip attributes coming from ohai
    next if precedence == :automatic

    next unless [:debug, :trace].include?(Chef::Config[:log_level])

    frame = caller.find { |line| line.include?('cookbooks/') }
    # Example Entry
    # /etc/cinc/local-mode-cache/cache/cookbooks/fb_apt/resources/sources_list.rb:79:in 'block class_from_file'
    filename, line_number = frame.split(':')
    location = "#{filename}:#{line_number}"
    Chef::Log.debug(
      "attribute_changed: key: #{key}, value: #{value}, precedence: #{precedence} at #{location}",
    )
    # Trying out improved form
    Chef::Log.debug(
      "- node.#{precedence}#{key.map { |n| "[\"#{n}\"]" }.join} = #{value} at #{location}",
    )
  end
end
