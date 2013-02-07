module CTA
  class TrainTracker
    class Estimate
      attr_reader :station_id, :stop_id, :station_name, :stop_description, :run_number, :route, :destination_stop_id, :destination_name, :direction, :timestamp, :arrival_time, :approaching, :schedule, :fit, :delay

      def initialize(params)
        params.each do |key, value|
          self.instance_variable_set("@#{ key }".to_sym, value)
        end
      end
    end
  end
end