_         = require 'lodash'
fs        = require 'fs'


class FoxxMC
  Utils: {}
  Scripts: {}


files = _.chain fs.listTree __dirname
  .filter (i) ->
    not /index\.js/.test(i) and fs.isFile fs.join __dirname, i
  .map (i) -> i.replace /\.js$/, ''
  .orderBy()
  .value()
for file in files
  require(fs.join __dirname, file) FoxxMC


module.exports = FoxxMC
