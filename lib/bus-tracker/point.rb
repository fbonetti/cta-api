module CTA
  class BusTracker
    class Pattern
      class Point
        attr_reader :sequence, :latitude, :longitude, :type, :id, :name, :distance

        def initialize(params)
          params.each do |key, value|
            self.instance_variable_set("@#{ key }".to_sym, value)
          end
        end
      end
    end
  end
end