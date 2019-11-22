module.exports = (kira) ->
  request = require 'request'

  kira.intent 'get_favorite', (cmd) ->
      query = cmd.match.object[0].value
      query = query.toLowerCase()
      query = query.replace /\?+$/g, ""
      query = query.replace /^\s+|\s+$/g, ""
      kira.find "SELF", "favorite:" + query, (fav) ->
        if fav?
          cmd.reply "My favorite " + query + "? I like this: "
          cmd.reply fav
        else
          findImage query, null, (err, image) ->
            if err or !(image?)
              cmd.reply "There was an error processing that request."
            else
              random = image.responseData?.results[Math.floor(Math.random()*image.responseData?.results.length)]
              cmd.reply "My favorite " + query + "? I like this: "
              cmd.reply random.url
              kira.remember "SELF", "favorite:" + query, random.url, (res) ->
                if res?
                else
                  cmd.reply "Oops, looks like there was an error adding that to my memory."

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
