require 'FoxxMC'


result = FoxxMC::Scripts.sendSignal ROOT: "#{__dirname}/../../"


module.exports = result
