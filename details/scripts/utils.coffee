express = require 'express'
bodyParser = require 'body-parser'

port = 8090

# web
app = express()
app.use bodyParser.urlencoded({ extended: true})
router = express.Router()
router.get '/', (req, res) ->
    res.json({ ok: true })
app.use '/api', router
app.listen port
console.log "Listening on port #{port}"

module.exports = (kira) ->

  kira.intent 'do_restart', (cmd) ->
    if cmd.admin or cmd.is_admin
      cmd.reply "Restarting..."
      setTimeout ( ->
        process.exit 0
      ), 2000
    else
      cmd.reply "Sorry, you need to be a Slack team admin or bot admin to trigger a restart."

  kira.intent 'join_channel', (cmd) ->
    if cmd.admin or cmd.is_admin
      cmd.reply "Joining..."
      cmd.invite()
    else
      cmd.reply "Not an admin."
