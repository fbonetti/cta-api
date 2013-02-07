module CTA
  class BusTracker
    class ServiceBulletin
      attr_reader :name, :subject, :detail, :brief, :priority, :services

      def initialize(params)
        params.each do |key, value|
          self.instance_variable_set("@#{ key }".to_sym, value)
        end
      end
    end
  end
end