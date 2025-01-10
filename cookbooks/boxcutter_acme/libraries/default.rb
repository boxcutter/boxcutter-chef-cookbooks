module Boxcutter
  class Acme
    def self.to_bash_array(ruby_array)
      bash_array = ruby_array.map { |item| "\"#{item}\"" }.join(' ')
      "(#{bash_array})"
    end
  end
end
