module CTA
  class BusTracker

    def initialize(key)
      @key = key
    end

    def time
      base_url = "http://www.ctabustracker.com/bustime/api/v1/gettime?"
      url = "#{ base_url}key=#{ @key }"
      Time.parse(Nokogiri::XML(open(url)).at("//tm").text)
    end

    def vehicles_by_routes(routes)
      if routes.kind_of?(Array)
        full_array = []
        until routes.size == 0
          full_array << vehicles(route: routes.shift(10))
        end
        full_array.flatten!
      else
        raise ArgumentError.new "Argument must be an Array."
      end
    end

    def vehicles_by_ids(vids)
      if vids.kind_of?(Array) && routes.size.between(1,10)
        vehicles(vid: vids)
      else
        raise ArgumentError.new "must be an Array with 1 to 10 elements."
      end
    end

    def patterns_by_route(route)
      if route.kind_of?(String) && route.length > 0
        patterns(route: route)
      else
        raise ArgumentError.new "must be a String with a length greater than zero."
      end
    end

    def patterns_by_ids(pid)
      if pid.kind_of?(Array) && pid.size.between?(1,10)
        patterns(pid: pid)
      else
        raise ArgumentError.new "must be an Array with 1 to 10 elements."
      end
    end

    def predictions_by_stop_ids(stop_id, route="")
      if stop_id.kind_of?(Array) && stop_id.size.between?(1,10)
        predictions(stop_id: stop_id, route: route)
      else
        raise ArgumentError.new "must be an Array with 1 to 10 elements."
      end
    end

    def predictions_by_vehicle_ids(vid)
      if vid.kind_of?(Array) && vid.size.between?(1,10)
        predictions(vid: vid)
      else
        raise ArgumentError.new "must be an Array with 1 to 10 elements."
      end
    end

    def routes
      base_url = "http://www.ctabustracker.com/bustime/api/v1/getroutes?"
      url = "#{ base_url }key=#{ @key }"
      route_hash = {}
      Nokogiri::XML(open(url)).xpath("//route").each do |route|
        route_hash[route.at("rt").text] = route.at("rtnm").text
      end
      route_hash
    end

    def route_directions(route)
      if route.kind_of?(String)
        base_url = "http://www.ctabustracker.com/bustime/api/v1/getdirections?rt=#{ route }"
        url = "#{ base_url }&key=#{ @key }"
        Nokogiri::XML(open(url)).xpath("//dir").map { |x| x.text.split(/ /)[0].to_sym }
      end
    end

    def stops(route, direction)
      if (route.kind_of?(String) || route.kind_of?(Integer)) && direction.kind_of?(Symbol)
        direction = direction.to_s + "+bound"
        base_url = "http://www.ctabustracker.com/bustime/api/v1/getstops?"
        url = "#{ base_url }key=#{ @key }&rt=#{ route }&dir=#{ direction }"

        stop_array = Nokogiri::XML(open(url)).xpath("//stop").map do |item|
          Stop.new({
            :id => item.at("stpid").text,
            :name => item.at("stpnm").text,
            :latitude => item.at("lat").text,
            :longitude => item.at("lon").text
          })
        end
        stop_array
      end
    end

    def service_bulletins(params)
      route = params[:route] || []
      route_direction = params[:route_direction]
      stop_id = params[:stop_id] || []

      base_url = "http://www.ctabustracker.com/bustime/api/v1/getservicebulletins?"
      url = "#{ base_url }key=#{ @key }&rt=#{ route.join(',') }&rtdir=#{ route_direction }&stpid=#{ stop_id.join(',') }"
      puts url

      bulletin_array = Nokogiri::XML(open(url)).xpath("//sb").map do |item|
        ServiceBulletin.new({
          :name => item.at("nm") && item.at("nm").text,
          :subject => item.at("sbj") && item.at("sbj").text,
          :detail => item.at("dtl") && item.at("dtl").text.gsub("<br/>", "\n").strip,
          :brief => item.at("brf") && item.at("brf").text,
          :priority => item.at("prty") && item.at("prty").text,
          :services => item.xpath("srvc") && item.xpath("srvc").map do |subitem|
            ServiceBulletin::Service.new({
              :route => subitem.at("rt") && subitem.at("rt").text,
              :route_direction => subitem.at("rtdir") && subitem.at("rtdir").text,
              :stop_id => subitem.at("stpid") && subitem.at("stpid").text,
              :stop_name => subitem.at("stpnm") && subitem.at("stpnm").text
            })
          end
        })
      end
      bulletin_array
    end

    private

    def vehicles(params)
      route = params[:route] || []
      vid = params[:vid] || []

      base_url = "http://www.ctabustracker.com/bustime/api/v1/getvehicles?"
      url = "#{ base_url }key=#{ @key }&rt=#{ route.join(",") }&vid=#{ vid.join(",") }"

      vehicle_array = Nokogiri::XML(open(url)).xpath("//vehicle").map do |item|
        Vehicle.new({
          :id => item.at("vid").text,
          :timestamp => Time.parse(item.at("tmstmp").text),
          :latitude => item.at("lat").text,
          :longitude => item.at("lon").text,
          :heading => item.at("hdg").text,
          :pattern_id => item.at("pid").text,
          :pattern_distance => item.at("pdist").text,
          :destination => item.at("des").text,
          :delay => item.at("dly") && item.at("dly").text.to_bool
        })
      end
      vehicle_array
    end

    def patterns(params)
      route = params[:route]
      pid = params[:pid] || []

      base_url = "http://www.ctabustracker.com/bustime/api/v1/getpatterns?"
      url = "#{ base_url }key=#{ @key }&rt=#{ route }&pid=#{ pid.join(",") }"

      pattern_array = Nokogiri::XML(open(url)).xpath("//ptr").map do |item|
        Pattern.new({
          :id => item.at("pid").text,
          :length => item.at("ln").text.to_f,
          :direction => item.at("rtdir").text,
          :points => item.xpath("pt").map do |subitem|
            Pattern::Point.new({
              :sequence => subitem.at("seq").text,
              :latitude => subitem.at("lat").text,
              :longitude => subitem.at("lon").text,
              :type => subitem.at("typ").text == "S" ? "stop" : "waypoint",
              :id => subitem.at("stpid") && subitem.at("stpid").text,
              :name => subitem.at("stpnm") && subitem.at("stpnm").text,
              :distance => subitem.at("pdist") && subitem.at("pdist").text
            })
          end
        })
      end
      pattern_array
    end

    def predictions(params)
      stop_id = params[:stop_id] || []
      route = params[:route] || []
      vid = params[:vid] || []

      base_url = "http://www.ctabustracker.com/bustime/api/v1/getpredictions?"
      url = "#{ base_url }key=#{ @key }&stpid=#{ stop_id.join(',') }&rt=#{ route.join(',') }&vid=#{ vid.join(',') }"

      prediction_array = Nokogiri::XML(open(url)).xpath("//prd").map do |item|
        Prediction.new({
          :timestamp => Time.parse(item.at("tmstmp").text),
          :type => item.at("typ").text == "A" ? "arrival" : "departure",
          :stop_name => item.at("stpnm").text,
          :vehicle_id => item.at("vid").text,
          :distance_from_stop => item.at("dstp").text.to_f,
          :route => item.at("rt").text,
          :route_direction => item.at("rtdir").text,
          :destination => item.at("des").text,
          :predicted_time => Time.parse(item.at("prdtm").text)
        })
      end
      prediction_array
    end
  end
end