module Boxcutter
  class AttributeChangeHandler < Chef::Handler
    def report
      puts 'MISCHA: AttributeChangeHandler'
    end
  end
end

Chef.event_handler do
  on :attribute_changed do |precedence, keys, value|
    # Skip attributes coming from ohai
    next if precedence == :automatic

    frame = caller.find { |line| line.include?('cookbooks/') }
    puts "MISCHA: frame=#{frame}"

    puts "MISCHA: precedence: #{precedence}, keys: #{keys}, value: #{value}"
  end
end
