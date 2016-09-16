require 'cta-api'
require 'pry'

describe CTA::CustomerAlerts do
  context "routes" do
    it "can get status on a single train route" do
      options = {
        :routeid => "red",
      }

      routes = CTA::CustomerAlerts.routes(options)
      expect(routes.count).to eq(1)
      expect(routes.first["Route"]).to eq("Red Line")
    end

    it "can get status from multiple train routes" do
      route_list = CTA::CustomerAlerts.train_routes

      options = {
        :routeid => "red,blue",
      }

      routes = CTA::CustomerAlerts.routes(options)
      expect(routes.count).to eq(2)
      route_names = routes.flat_map { |r| r["Route"] }
      expect(route_names).to contain_exactly("Red Line", "Blue Line")
    end

    it "can get status on a single bus route" do
      options = {
        :routeid => "8",
      }

      routes = CTA::CustomerAlerts.routes(options)
      expect(routes.count).to eq(1)
      expect(routes.first["Route"]).to eq("Halsted")
    end

    it "can get from multiple bus routes" do
      route_list = CTA::CustomerAlerts.bus_routes

      options = {
        :routeid => "36,8"
      }

      routes = CTA::CustomerAlerts.routes(options)
      expect(routes.count).to eq(2)
      route_names = routes.flat_map { |r| r["Route"] }
      expect(route_names).to contain_exactly("Broadway", "Halsted")
    end

    it "can get status from a station id" do
      options = {
        :stationid => "40830"
      }

      routes = CTA::CustomerAlerts.routes(options)
      expect(routes.count).to eq(1)
      expect(routes.first["Route"]).to eq("18th | 1710 W. 18th St., Chicago, IL 60608")
    end

    it "prints an error message on an invalid request" do
      expect(STDOUT).to receive(:puts).with("API ERROR: Invalid parameter: 'not_a_field'. Error code: 500")

      options = {
        :not_a_field => "error"
      }
      routes = CTA::CustomerAlerts.routes(options)
    end
  end

  context "alerts" do
    it "can get a list of alerts" do
      alerts = CTA::CustomerAlerts.alerts
      expect(alerts).to_not be_empty
    end

    it "can get a list of alerts with options specified" do
      options = {
        :activeonly => true,
      }
      alerts = CTA::CustomerAlerts.alerts(options)
      expect(alerts).to_not be_empty
    end
  end
end
