module Boxcutter
  class Prometheus
    module Helpers
      # Convert hash entry when key is name 'index_.*' to an array
      def self.h_to_a(obj)
        if obj.is_a?(Hash)
          obj = if obj.keys.any? { |k| !k.to_s.start_with?('index_') } || obj.empty?
                  obj.transform_values { |v| h_to_a(v) }
                else
                  obj.values
                end
        end
        obj.is_a?(Array) ? obj.map { |v| h_to_a(v) } : obj
      end
    end
  end
end
