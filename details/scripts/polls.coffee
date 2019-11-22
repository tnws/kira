module.exports = (kira) ->
  _ = require('underscore')
  poll = {}
  poll.active = false
  poll.question = ""
  poll.options = []
  poll.ts = null
  poll.channel = null


  kira.intent 'start_poll', (cmd) ->
    console.log cmd.match


    if !(cmd.match.poll_options?) or !(cmd.match.poll_question?)
      cmd.reply "Please start a poll using `kira start poll with question {question} with options {options}`, and make sure that your options are comma separated (example: `Dog, Cat, Hamster`)."
      return

    if poll.active
      cmd.reply "There is already a poll in progress! Please try again later."
      return

    emojis = ["fire", "confetti_ball", "sunglasses", "thumbsup", "sparkles", "crown", "tophat", "zap", "bulb"]

    options = cmd.match.poll_options[0].value.split(', ')

    poll.active = true
    for i in options
      chosenEmoji = emojis[Math.floor(Math.random() * emojis.length)]
      emojis.splice emojis.indexOf(chosenEmoji), 1
      poll.options.push {option: i, emoji: chosenEmoji}

    poll.question = cmd.match.poll_question[0].value

    console.log " !  Creating poll... Question: #{poll.question} :: Options: #{options}"
    message = "_Poll Created!_\nPlease choose your vote, using emoji reactions. *Question:* #{poll.question}\n\n"
    for i in poll.options
      message += ":#{i.emoji}: : #{i.option}\n"

    cmd.postMessage message, {as_user: true}, (callback) ->
      poll.ts = callback.ts
      poll.channel = callback.channel
      for i in poll.options
        cmd.react i.emoji, callback.channel, callback.ts

  kira.intent 'end_poll', (cmd) ->
    if poll.active
      console.log " !  Ending poll. Getting and posting results..."
      poll.active = false

      pollEndStatus = []
      kira.web.reactions.get {channel: poll.channel, timestamp: poll.ts}, (err, response) ->
        results = response.message.reactions
        results = _.sortBy(results, 'count')
        results = results.reverse()
        winningChoice = results[0]
        winningChoice = _.findWhere(poll.options, {emoji: winningChoice.name})
        message = "_The poll has ended by the request of <@#{cmd.sender}>._\n\nIn response to the poll entitled \"_#{poll.question}_\", the winner is: \n\n :#{winningChoice.emoji}: *#{winningChoice.option}* :#{winningChoice.emoji}:"
        cmd.reply message
        clearPoll()

        # TODO: check for any ties
        # TODO: show winning choice
        # TODO: show rest of choices


    else
      cmd.reply "There is no poll in progress right now."

    clearPoll = () ->
      poll = {}
      poll.active = false
      poll.question = ""
      poll.options = []
      poll.ts = null
      poll.channel = null
