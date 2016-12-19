require 'FoxxMC'


result = FoxxMC::Scripts.migrate ROOT: "#{__dirname}/../../"


module.exports = result
