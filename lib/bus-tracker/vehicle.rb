module CTA
  class BusTracker
    class Vehicle
      attr_reader :id, :timestamp, :latitude, :longitude, :heading, :pattern_id, :pattern_distance, :destination, :delay

      def initialize(params)
        params.each do |key, value|
          self.instance_variable_set("@#{ key }".to_sym, value)
        end
      end
    end
  end
end