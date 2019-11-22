fs = require 'fs'

module.exports = () ->
  files = fs.readdirSync './details/scripts'
  scripts = []

  for file in files
    scripts.push require './scripts/' + file
  return scripts