module Boxcutter
  class AttributeChangeHandler < Chef::Handler
    def report
      puts 'MISCHA: AttributeChangeHandler'
    end
  end
end

Chef.event_handler do
  on :attribute_changed do |precedence, next_path, value|
    # Skip attributes coming from ohai
    next if precedence == :automatic

    frame = caller.find { |line| line.include?('cookbooks/') }
    puts "MISCHA: frame=#{frame}"

    puts "MISCHA: precedence: #{precedence}, next_path: #{next_path}, value: #{value}"
  end
end
