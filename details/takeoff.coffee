Kira = require './kira'
RtmClient = require('@slack/client').RtmClient
WebClient = (require '@slack/client').WebClient
MemoryDataStore = require('@slack/client').MemoryDataStore
RTM_CLIENT_EVENTS = require('@slack/client').CLIENT_EVENTS.RTM
loader = require './loader'
fs = require 'fs'

client = undefined
kira = undefined
config = 'api.txt'

takeoff = () ->
	key = fs.readFileSync config, encoding: 'utf8'
	key = key.replace /^\s+|\s+$/g, ""
	rtm = new (RtmClient)(key, dataStore: new MemoryDataStore)
	web = new WebClient key

	rtm.on RTM_CLIENT_EVENTS.AUTHENTICATED, (data) ->
		console.log "Logged in to #{data.team.name} as #{data.self.name}."

		kira = new Kira rtm, web

		scripts = loader()
		for script in scripts
			script kira

	rtm.on 'close', () ->
		console.log "Exited."
		process.exit 1


	rtm.start()

module.exports = takeoff
