module CTA
  class BusTracker
    class Pattern
      attr_reader :id, :length, :direction, :points

      def initialize(params)
        params.each do |key, value|
          self.instance_variable_set("@#{ key }".to_sym, value)
        end
      end
    end
  end
end