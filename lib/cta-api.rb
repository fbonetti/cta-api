require 'rubygems'
require 'httparty'
require 'hashie'
require 'csv'
require 'time'

class Array
  def self.wrap(object)
    if object.nil?
      []
    elsif object.respond_to?(:to_ary)
      object.to_ary || [object]
    else
      [object]
    end
  end
end

module CTA
  class BusTracker
    include HTTParty
    base_uri 'http://www.ctabustracker.com/bustime/api/v1'
    format :xml
    @@key = nil

    def self.time(options={})
      options.merge!({
        :key => @@key
      })

      response = get("/gettime", :query => options)['bustime_response']
      check_for_errors response['error']

      Time.parse response['tm']
    end

    def self.vehicles(options={})
      options.merge!({
        :key => @@key
      })
      options[:vid] = options[:vid].join(',') if options[:vid].kind_of?(Array)
      options[:rt] = options[:rt].join(',') if options[:rt].kind_of?(Array)

      response = get("/getvehicles", :query => options)['bustime_response']
      check_for_errors response['error']

      results = Array.wrap response['vehicle']
      results.map { |result| Hashie::Mash.new result } unless results.nil?
    end

    def self.routes(options={})
      options.merge!({
        :key => @@key
      })

      response = get("/getroutes", :query => options)['bustime_response']
      check_for_errors response['error']

      results = Array.wrap response['route']
      Hash[ results.map { |result| [result['rt'], result['rtnm']] } ] unless results.nil?
    end

    def self.directions(options={})
      options.merge!({
        :key => @@key
      })

      response = get("/getdirections", :query => options)['bustime_response']
      check_for_errors response['error']

      results = Array.wrap response['dir']
      results.map { |direction| direction.split(/ /)[0].downcase.to_sym } unless results.nil?
    end

    def self.stops(options={})
      options.merge!({
        :key => @@key
      })
      options[:dir] = "#{options[:dir]} bound" if options[:dir].kind_of?(Symbol)

      response = get("/getstops", :query => options)['bustime_response']
      check_for_errors response['error']

      results = Array.wrap response['stop']
      results.map { |result| Hashie::Mash.new result } unless results.nil?
    end

    def self.patterns(options={})
      options.merge!({
        :key => @@key
      })
      options['pid'] = options['pid'].join(',') if options['pid'].kind_of?(Array)

      response = get("/getpatterns", :query => options)['bustime_response']
      check_for_errors response['error']

      results = Array.wrap response['ptr']
      results.map { |result| Hashie::Mash.new result } unless results.nil?
    end

    def self.predictions(options={})
      options.merge!({
        :key => @@key
      })
      options['stpid'] = options['stpid'].join(',') if options['stpid'].kind_of?(Array)
      options['rt'] = options['rt'].join(',') if options['rt'].kind_of?(Array)
      options['vid'] = options['vid'].join(',') if options['vid'].kind_of?(Array)

      response = get("/getpredictions", :query => options)['bustime_response']
      check_for_errors response['error']

      results = Array.wrap response['prd']
      results.map { |result| Hashie::Mash.new result } unless results.nil?
    end

    def self.bulletins(options={})
      options.merge!({
        :key => @@key
      })
      options['rt'] = options['rt'].join(',') if options['rt'].kind_of?(Array)
      options['stpid'] = options['stpid'].join(',') if options['stpid'].kind_of?(Array)

      response = get("/getservicebulletins", :query => options)['bustime_response']
      check_for_errors response['error']

      results = Array.wrap response['sb']
      results.map { |result| Hashie::Mash.new result } unless results.nil?
    end

    def self.key
      @@key
    end

    def self.key=(key)
      @@key = key
    end

    private

    def self.check_for_errors(error)
      puts "API ERROR: #{error['msg']}" if error
    end
  end

  class TrainTracker
    include HTTParty
    base_uri 'http://lapi.transitchicago.com/api/1.0'
    format :xml
    @@key = nil

    def self.arrivals(options={})
      options.merge!({
        :key => @@key
      })

      response = get("/ttarrivals.aspx", :query => options)['ctatt']
      check_for_errors response

      results = Array.wrap response['eta']
      results.map { |result| Hashie::Mash.new result } unless results.nil?
    end

    def self.follow(options={})
      options.merge!({
        :key => @@key
      })

      response = get("/ttfollow.aspx", :query => options)['ctatt']
      check_for_errors response

      etas = Array.wrap response['eta']
      etas = etas.map { |eta| Hashie::Mash.new eta } unless etas.nil?
      Hashie::Mash.new({ :eta => etas, :position => Hashie::Mash.new(response['position']) })
    end

    def self.locations(options={})
      options.merge!({
        :key => @@key
      })

      response = get("/ttpositions.aspx", :query => options)['ctatt']
      check_for_errors response

      results = Array.wrap response['route']
      results.map { |result| Hashie::Mash.new result } unless results.nil?
    end

    def self.stops
      stops = stop_table.map { |stop| [stop['STOP_ID'], stop['STOP_NAME']] }.flatten
      Hash[*stops]
    end

    def self.stations
      stations = stop_table.map { |stop| [stop['PARENT_STOP_ID'], stop['STATION_DESCRIPTIVE_NAME']] }.flatten
      Hash[*stations]
    end

    def self.stop_table
      stop_data = []
      CSV.read(File.dirname(__FILE__) + "/cta_L_stops.csv").each_with_index do |line, index|
        index == 0 ? @headers = line : stop_data << Hash[ @headers.zip line ]
      end
      stop_data
    end

    def self.key
      @@key
    end

    def self.key=(key)
      @@key = key
    end

    private

    def self.check_for_errors(error)
      puts "API ERROR: #{error['errNm']}. Error code: #{error['errCd']}" if error['errCd'] != "0"
    end
  end
end
