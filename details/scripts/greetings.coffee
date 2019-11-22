module.exports = (kira) ->
  moment = require 'moment'
  startup = do moment

  kira.intent 'greetings', (cmd) ->
    name = ''
    ways_to_say_hi = [
      "Hey there.",
      "Hi.",
      "'ello.",
      "Hey.",
      "Hi there."
    ]

    cmd.react "wave", cmd.channel, cmd.rawMessage.ts
