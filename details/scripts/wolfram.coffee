module.exports = (kira) ->

  Wolfram = require('wolfram').createClient("WOLFRAM TOKEN HERE")
  
  util = require('util')

  kira.intent 'wolfram', (cmd) ->
    query = cmd.match.wolfram_search_query[0].value
    if query
      kira.client._send {"id":"1","type":"typing","channel":cmd.channel["id"]}
      Wolfram.query query, (e, result) ->
        if result? and result[1]?
          result = result[1]['subpods'][0]
          send =
            as_user: true
            channel: cmd.channel["id"]
            attachments: [
              color: "7CD197"
              fallback: "#{query} - #{result}"
              author_name: cmd.sender.real_name
              author_icon: cmd.sender.profile.image_72
              fields: [
                {
                  title: query
                  value: result['value']
                }
              ]
            ]
          if result['image']? and value = ""
            send.attachments[0].fields[0].value = ""
            send.attachments[0].image_url = result['image']
          cmd.channel.postMessage send
        else
          cmd.reply "Sorry, Wolfram Alpha doesn't understand `#{query}`. ¯\\_(ツ)_/¯"
