_         = require 'lodash'
fs        = require 'fs'


class FoxxMC
  Utils: {}
  Scripts: {}


files = _.chain fs.listTree __dirname
  .filter (i) ->
    console.log '????? filter in FoxxMC i', i
    not /index\.js/.test(i) and fs.isFile fs.join __dirname, i
  .map (i) -> i.replace /\.js$/, ''
  .orderBy()
  .value()
for file in files
  console.log '????? for in FoxxMC file', file
  require(fs.join __dirname, file) FoxxMC


module.exports = FoxxMC
