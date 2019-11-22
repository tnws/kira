module.exports = (kira) ->
  Wiki = require 'wikijs'
  wiki = new Wiki()

  String::capitalize = ->
      @replace /(^|\s)([a-z])/g, (m, p1, p2) ->
        p1 + p2.toUpperCase()

  kira.intent 'get_wiki', (cmd) ->
    query = cmd.match.search_query[0].value
    query = query.replace(/^<https?:\/\/(.*)\|/g, "")
    query = query.replace(/>/g, "")
    query = query.toLowerCase().capitalize()
    wiki.page(query).then (page) ->
      if page
        fullURL = page.fullurl
        search = page.title
        page.summary().then (info) ->
          console.log info
          if info
            info = info.replace(/\r?\n(.*)|\r/g, "")
            send =
              as_user: true
              unfurl_links: false
              channel: cmd.channel
              attachments: [
                pretext: "_Okay, here you go:_"
                color: "#065A82"
                fallback: "Wikipedia"
                title: page.title
                title_link: page.fullurl
                text: info
                mrkdwn_in: ['pretext']

              ]

            kira.web.chat.postMessage cmd.channel, "ok", send
          else
            cmd.reply "I couldn't find info on _#{query}_. Try changing your query around."
      else
        cmd.reply "I couldn't find info on _#{query}_. Try changing your query around."
