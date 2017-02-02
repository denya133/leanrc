FoxxMC      = require 'FoxxMC'


result = FoxxMC::Scripts.touchQueue
  ROOT: "#{__dirname}/../../"
  context: module.context


module.exports = result
