Chef.event_handler do
  on :attribute_changed do |precedence, key, value|
    # Skip attributes coming from ohai
    next if precedence == :automatic

    frame = caller.find { |line| line.include?('cookbooks/') }
    puts "MISCHA: frame=#{frame}"

    puts "MISCHA: setting attribute #{precedence}#{key.map { |n| "[\"#{n}\"]" }.join} = #{value}"
    puts "MISCHA: precedence: #{precedence}, key: #{key}, value: #{value}"
  end
end
