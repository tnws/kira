module.exports = (kira) ->

  moment = require 'moment'
  fs = require 'fs'
  startup = do moment
  request = require 'request'
  git = require 'gift'
  repo = git __dirname
  commit = undefined
  token = "GITHUB TOKEN HERE"
  repo.current_commit (err, lc) ->
    if !err and lc?
      commit = lc
    else
      file = 'revision.txt'
      fs.stat file, (err, stats) ->
        if !err and stats.isFile()
          rev = fs.readFileSync file, encoding: 'utf8'
          rev = rev.replace /^\s+|\s+$/g, ""
          if rev?
            url = "https://api.github.com/repos/tnws/Kira/commits/#{rev}?access_token=#{token}"
            request.get url, {
              headers: {
                'User-Agent': 'Mozilla/5.0 (Kira)'
              }
            }, (err, resp, body) ->
              if !err and body?
                body = JSON.parse body
                commit =
                  message: body.commit.message.replace(/\n+/g, "; ")
                  author: "#{body.commit.author.name} <#{body.commit.author.email}>"
                  id: body.sha

  kira.intent 'get_status', (cmd) ->
    message = "Start up: *#{startup.fromNow()}*\n"
    message += "Redis: "
    if kira.redis?
      message += "*connected*\n"
    else
      message += "*not connected*\n"
    if commit?
      message += "Version `#{commit.id.substring(0, 7)}`:\n"
      message += "> \"#{commit.message}\"\n"
      message += "> _-#{commit.author}_"
    cmd.reply message
