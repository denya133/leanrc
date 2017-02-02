FoxxMC      = require 'FoxxMC'


result = FoxxMC::Scripts.sendSignal
  ROOT: "#{__dirname}/../../"
  context: module.context


module.exports = result
