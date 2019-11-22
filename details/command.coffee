admins = [''] # hard-coded admin IDs

class Command

	constructor: (@rtm, @web, @sender, @text, @match, @channel, @rawMessage) ->
		@admin = @sender.id in admins

	reply: (msg, callback) ->
		@rtm.sendMessage msg, @channel

	postMessage: (text, toSend, callback) ->
		@web.chat.postMessage @channel, text, toSend, (err, resp) ->
			if callback?
				callback resp

	react: (emoji, channel, ts) ->
		@web.reactions.add emoji, {channel: channel, timestamp: ts}

	unreact: (emoji, channel, ts) ->
		@web.reactions.remove emoji, {channel: channel, timestamp: ts}

	getReactions: (channel, ts) ->
		@web.reactions.get {channel: channel, timestamp: ts}

	getReactionsFromUser: (user) ->
		@web.reactions.list {user: user}

	topic: (topic) ->
		switch @channel.substr(0, 1)
			when "G" then @web.groups.setTopic @channel, topic
			when "C" then @web.channels.setTopic @channel, topic
			else null

	purpose: (purpose) ->
		switch @channel.substr(0, 1)
			when "G" then @web.groups.setPurpose @channel, topic
			when "C" then @web.channels.setPurpose @channel, topic
			else null

	delete: (channel, ts) ->
		@web.chat.delete ts, channel


	isAdmin: (id) ->
		return id in admins



module.exports = Command
