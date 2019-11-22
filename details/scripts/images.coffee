module.exports = (kira) ->

  request = require 'request'

  kira.intent 'get_image', (cmd) ->
    query = cmd.match.search_query[0].value

    findImage query, null, (err, image) ->
      if err or !(image?)
        cmd.reply "There was an error processing that request."
      else
        random = image.responseData?.results[Math.floor(Math.random()*image.responseData?.results.length)]
        cmd.reply unescape random.url

  findImage = (query, type, callback) ->
    url = "https://ajax.googleapis.com/ajax/services/search/images?v=1.0&q=" + query
    if type == "gif"
      url += "&as_filetype=" + type
    request.get url, {
      headers: {
        'User-Agent': 'Mozilla/5.0 (Kira)'
      }
    }, (err, resp, body) ->
      if !err and body?
        body = JSON.parse body
        callback undefined, body
      else
        callback new Error 'could not find image'
