module CTA
  class BusTracker
    class Stop
      attr_reader :id, :name, :latitude, :longitude

      def initialize(params)
        params.each do |key, value|
          self.instance_variable_set("@#{ key }".to_sym, value)
        end
      end
    end
  end
end