FoxxMC      = require 'FoxxMC'


result = FoxxMC::Scripts.rollback
  ROOT: "#{__dirname}/../../"
  context: module.context


module.exports = result
