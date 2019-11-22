module.exports = (kira) ->

  Forecast = require 'forecast'
  geocoderProvider = 'google'
  httpAdapter = 'http'
  geo = require('node-geocoder')(geocoderProvider, httpAdapter)

  forecast = new Forecast(
    service: 'forecast.io'
    key: 'FORECAST IO TOKEN HERE'
    units: 'fahrenheit'
    cache: false
    ttl:
      minutes: 27
      seconds: 45)

  kira.intent 'set_location', (cmd) ->
    place = cmd.match.location[0].value
    geo.geocode place, (err, location) ->
      if location? and !err
        kira.remember cmd.sender.id, "home:loc:text", location[0].formattedAddress, (res) ->
          if res?
            kira.remember cmd.sender.id, "home:loc:coords", [location[0].latitude, location[0].longitude], (res) ->
              if res?
                cmd.reply "Okay, I'll remember that."
              else
                cmd.reply "Oops, looks like there was an error adding that location to my memory."
          else
            cmd.reply "There was an error doing that. Please try again later, or try a different place."
      else
        cmd.reply "I couldn't find a place with that name."

  kira.intent 'get_weather', (cmd) ->
    if cmd.match.location?
      geo.geocode cmd.match.location[0].value, (err, location) ->
        if err or !location
          cmd.reply "Couldn't find a place with that name."
        else
          forecast.get [location[0].latitude, location[0].longitude], (err, weather) ->
            if err or !weather
              cmd.reply "Couldn't find information for that location."
            else
              cmd.reply "It's currently *#{weather.currently.summary.toLowerCase()}* with a temperature of *#{weather.currently.temperature}°F [#{convert(weather.currently.temperature)}°C]* _(feels like #{weather.currently.apparentTemperature}°F [#{convert(weather.currently.apparentTemperature)}°C])_. #{weather.hourly.summary}"
    else
      kira.find cmd.sender.id, "home:loc:coords", (coords) ->
        if coords?
          forecast.get coords.split(), (err, weather) ->
            if !err and weather?
              kira.find cmd.sender.id, "home:loc:text", (text) ->
                if text?
                  cmd.reply "It's currently *#{weather.currently.summary.toLowerCase()}* in _#{text}_, with a temperature of *#{weather.currently.temperature}°F [#{convert(weather.currently.temperature)}°C]* _(feels like #{weather.currently.apparentTemperature}°F [#{convert(weather.currently.apparentTemperature)}°C])_. #{weather.hourly.summary}"
        else
          cmd.reply "I don't know where you live. Try setting it with `kira i live in {location}`." 

  convert = (temp) ->
    return Math.round(100*(temp - 32) * 5 / 9)/100;