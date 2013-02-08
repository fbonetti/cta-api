## Install

Via rubygems.org:

```
$ gem install cta-api
```

## Usage

This gem allows you to access the Chicago Transit Authority API via Ruby. You can track the real-time locations of all public transportation vehicles, including buses and trains. You can obtain API keys from the CTA website:

* http://www.transitchicago.com/developers/bustracker.aspx
* http://www.transitchicago.com/developers/traintracker.aspx

## Bus Tracker

### Setup

``` ruby
require 'cta-api'

key = "XXXXXXXXXXXXXXXXXXXXXXXXX"
@tracker = CTA::TrainTracker.new(key)
```

### Find Routes and Stops

``` ruby
# list all available routes
@tracker.routes

# gets the available directions for the specified route (north, south, etc.)
@tracker.route_directions("50")

# list all stops that belong to a particular route
@tracker.stops("50", :north)
```

### Find Vehicles

``` ruby
# returns an array of vehicles that travel the given routes
@tracker.vehicles_by_routes(["50", "52A"])

# returns an array of vehicles with the given vehicle ids
@tracker.vehicles_by_ids(["1782", "1419", "1773"])
```

### Get Predicted Arrival Times

``` ruby
# get arrival times for a list of stop ids
# note that the second argument is optional
@tracker.predictions_by_stop_ids(["8751", "8752"], "50")

# get arrival times for a list of vehicle ids
@tracker.predictions_by_vehicle_ids(["1782", "1419", "1773"])
```

### Get System Time
``` ruby
@tracker.time
```

## Train Tracker

### Setup

``` ruby
require 'cta-api'

key = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
tracker = CTA::TrainTracker.new(key)
```

### Get a List of Stops and Stations

``` ruby
# stops
@tracker.stops

# stations
@tracker.stations
```

### Get Predicted Arrival Times

``` ruby
@tracker.arrivals stop_id: "30106"
```