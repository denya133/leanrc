require 'FoxxMC'


result = FoxxMC::Scripts.migrate
  ROOT: "#{__dirname}/../../"
  context: module.context


module.exports = result
