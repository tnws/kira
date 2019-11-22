module.exports = (kira) ->

  key = "SOUNDCLOUD TOKEN HERE"
  kira.intent 'get_track', (cmd) ->
    request = require 'request'
    query = cmd.match.search_query[0].value
    url = "http://api.soundcloud.com/tracks.json?client_id=#{key}&q=#{escape(query)}&limit=50"
    request.get url, {
      headers: {
        'User-Agent': 'Mozilla/5.0 (Kira)'
      }
    }, (err, resp, body) ->
      if !err and body?
        body = JSON.parse body
        cmd.reply "Okay, here's _#{body[0].title}_ uploaded by *#{body[0].user.username}*: #{body[0].permalink_url}"
      else
        cmd.reply "There was an error contacting SoundCloud. Please try again later."