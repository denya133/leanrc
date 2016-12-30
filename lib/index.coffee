_         = require 'lodash'
fs        = require 'fs'


global['FoxxMC'] = class FoxxMC
  Utils: {}
  Scripts: {}


files = _.chain fs.listTree __dirname
  .filter (i) -> fs.isFile fs.join __dirname, i
  .map (i) -> i.replace /\.js$/, ''
  .orderBy()
  .value()
for file in files
  require fs.join __dirname, file


module.exports = FoxxMC
