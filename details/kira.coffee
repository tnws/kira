class Kira

  Command = require './command'
  wit = require 'node-wit'
  Redis = require 'redis'
  RTM_EVENTS = require('@slack/client').RTM_EVENTS
  WebClient = require('@slack/client').WebClient
  find = require('lodash').find

  token = "WIT TOKEN HERE" ## wit.ai token


  team = ""
  debug = false
  name = "kira"
  reactEmoji = "bow"

  constructor: (@rtm, @web, @dataStore) ->
    self = @

    @intents = []

    #
    #  Connect to Redis
    #

    try
      @redis = Redis.createClient()
    catch err
      console.log "Could not connect to Redis."
      @redis = undefined

    @redis.on 'ready', () ->
      console.log "Connected to Redis."
      team = self.rtm.activeTeamId

    @redis.on 'error', (err) ->
      @redis = undefined

    @redis.on 'end', (err) ->
      @redis = undefined

    @rtm.on RTM_EVENTS.REACTION_ADDED, (reaction) ->
      channel = self.getChannelGroupOrDMById(reaction.item.channel).name
      if reaction.item.channel.substring(0, 1) == 'D'
        channel = self.getUserById(reaction.user).name
      console.log "+ reaction added in channel #{channel} by #{self.getUserById(reaction.user).name}"

    @rtm.on RTM_EVENTS.MESSAGE, (message) ->
      text = unescape(message.text)
      if !(message.subtype?)
        channel = "##{self.getChannelGroupOrDMById(message.channel).name}"
        if message.channel.substring(0, 1) == 'D'
          channel = self.getUserById(message.user).name
        console.log "(ts: #{message.ts}) #{channel} // #{self.getUserById(message.user).name} » #{text})"

      regex = ///^#{name}(.*)///i
      match = text.match(regex)

      if match?
        text = message.text.replace(///^#{name}///i, "")
        if text is ""
          return
        wit.captureTextIntent token, text, (err, res) ->
          if 0.75 > res.outcomes[0].confidence
            self.web.reactions.add "question", { channel: message.channel, timestamp: message.ts }
            return
          if err then console.log "Error: #{err}"
          self.handle message, message.channel, message.user, res


  handle: (message, channel, sender, response) ->
    text = message.text
    for intent in @intents
      if response.outcomes[0].intent == intent.name
        @web.reactions.add reactEmoji, { channel: message.channel, timestamp: message.ts }
        try
          intent.callback new Command(@rtm, @web, sender, text, response.outcomes[0].entities, channel, message)
        catch err
          @rtm.sendMessage "An awful error occurred. Please try again later.", channel
          console.log "Error: #{err}"

  intent: (name, callback) ->
    @intents.push {name: name, callback: callback}

  exists: (id, name, callback) ->
    if @redis?
      @redis.hexists "kira:#{team}:#{id}", name, (err, reply) ->
        if err?
          return null
        if reply? and reply is 0
          return false
        if reply? and reply is 1
          return true

  remember: (id, name, info, callback) ->
    if @redis?
      @redis.hset "kira:#{team}:#{id}", name, info, (err, reply) ->
        if err? and callback?
          callback err
        else
          if callback?
            callback reply
    else
      if callback?
        callback null

  away: () ->
    @web.users.setPresence 'away'

  active: () ->
    @web.users.setPresence 'auto'

  getUserById: (id) ->
    return @rtm.dataStore.users[id]

  getChannelById: (id) ->
    return @rtm.dataStore.channels[id]

  getGroupById: (id) ->
    return @rtm.dataStore.groups[id]

  getDMById: (id) ->
    return @rtm.dataStore.dms[id]

  getChannelGroupOrDMById: (objId) ->
    ret = undefined
    firstChar = objId.substring(0, 1)

    if firstChar == 'C'
      ret = @getChannelById(objId)
    else if firstChar == 'G'
      ret = @getGroupById(objId)
    else if firstChar == 'D'
      ret = @getDMById(objId)

    return ret

  forget: (id, callback) ->
    if @redis?
      @redis.del "kira:#{team}:#{id}", (err, reply) ->
        if err? and callback?
          callback err
        else
          if callback?
            callback reply
    else
      if callback?
        callback null

  find: (id, name, callback) ->
    if @redis?
      @redis.hget "kira:#{team}:#{id}", name, (err, reply) ->
        if err? and callback?
          callback err
        else
          if callback?
            callback reply
    else
      if callback?
        callback null

  dump: (id, callback) ->
    if @redis?
      @redis.hgetall "kira:#{team}:#{id}", (err, reply) ->
        if err? and callback?
          callback err
        else
          if callback?
            callback reply
    else
      if callback?
        callback null

module.exports = Kira
