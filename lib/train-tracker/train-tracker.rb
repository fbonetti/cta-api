module CTA
  class TrainTracker

    def initialize(key)
      @key = key
      @line_table = {
        :red => "Red",
        :blue => "Blue",
        :brown => "Brn",
        :orange => "Org",
        :purple => "P",
        :pink => "Pink",
        :yellow => "Y"
      }
    end

    def arrivals(params)
      station_id = params[:station_id]
      stop_id = params[:stop_id]
      max = params[:max]
      route = @line_table[params[:route]]

      base_url = "http://lapi.transitchicago.com/api/1.0/ttarrivals.aspx?"
      url = "#{ base_url }key=#{ @key }&mapid=#{ station_id }&stpid=#{ stop_id }&max=#{ max }&rt=#{ route }"

      estimate_array = Nokogiri::XML(open(url)).xpath("//eta").map do |item|
        Estimate.new({
          :station_id => item.at("staId").text,
          :stop_id => item.at("stpId").text,
          :station_name => item.at("staNm").text,
          :stop_description => item.at("stpDe").text,
          :run_number => item.at("rn").text,
          :route => @line_table.key(item.at("rt").text),
          :destination_stop_id => item.at("destSt").text,
          :destination_name => item.at("destNm").text,
          :direction => item.at("trDr").text,
          :timestamp => Time.parse(item.at("prdt").text),
          :arrival_time => Time.parse(item.at("arrT").text),
          :approaching => item.at("isApp").text.to_bool,
          :schedule => item.at("isSch").text.to_bool,
          :fit => item.at("isFlt").text.to_bool,
          :delay => item.at("isDly").text.to_bool
        })
      end
      estimate_array
    end

    def stops
      CSV.read("lib/cta_L_stops.csv").map { |x| {x[0] => x[2]} }
    end

    def stations
      CSV.read("lib/cta_L_stops.csv").map { |x| {x[7] => x[5]} }
    end
  end
end