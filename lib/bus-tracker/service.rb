module CTA
  class BusTracker
    class ServiceBulletin
      class Service
        attr_reader :route, :route_direction, :stop_id, :stop_name

        def initialize(params)
          params.each do |key, value|
            self.instance_variable_set("@#{ key }".to_sym, value)
          end
        end
      end
    end
  end
end