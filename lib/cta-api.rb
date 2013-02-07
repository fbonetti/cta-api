require 'nokogiri'
require 'open-uri'
require 'time'
require 'csv'

require 'bus-tracker/bus-tracker'
require 'bus-tracker/pattern'
require 'bus-tracker/stop'
require 'bus-tracker/vehicle'
require 'bus-tracker/point'
require 'bus-tracker/prediction'
require 'bus-tracker/service-bulletin'
require 'bus-tracker/service'
require 'train-tracker/train-tracker'
require 'train-tracker/estimate'

class String
  def to_bool
    return true   if self == true   || self =~ (/(true|t|yes|y|1)$/i)
    return false  if self == false  || self =~ (/(false|f|no|n|0)$/i)
    raise ArgumentError.new("invalid value for Boolean: \"#{self}\"")
  end
end