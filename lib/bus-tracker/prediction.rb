module CTA
  class BusTracker
    class Prediction
      attr_reader :timestamp, :type, :stop_name, :stop_id, :vehicle_id, :distance_from_stop, :route, :route_direction, :destination, :predicted_time

      def initialize(params)
        params.each do |key, value|
          self.instance_variable_set("@#{ key }".to_sym, value)
        end
      end
    end
  end
end