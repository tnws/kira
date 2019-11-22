module.exports = (kira) ->
  util = require 'util'
  request = require 'request'

  key = "WORDNIK TOKEN HERE" ## Wordnik API token here

  kira.intent 'get_definition', (cmd) ->
    word = cmd.match.search_query[0].value
    findDefinition word, (err, def) ->
      if err or !(def?)
        cmd.reply "Sorry, there was an issue finding a definition for _#{word}_."
      else
        if def[0] is undefined
          cmd.reply "Sorry, a definition couldn't be found for _#{word}_."
        else
          message = ""
          message += "*#{def[0].word}* (_#{def[0].partOfSpeech}_):\n"
          message += "> #{def[0].text}"
          cmd.reply message
 
  findDefinition = (word, callback) ->
    url = "http://api.wordnik.com:80/v4/word.json/#{escape(word)}/definitions?limit=200&includeRelated=true&useCanonical=false&includeTags=false&api_key=#{key}"
    request.get url, {
          headers: {
              'User-Agent': 'Mozilla/5.0 (Kira)'
          }
        }, (err, resp, body) ->
          if !err and body?
            body = JSON.parse body
            callback undefined, body
          else
            callback (err? ? err : new Error 'definition_unavailable')