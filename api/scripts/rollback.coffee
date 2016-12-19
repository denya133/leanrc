require 'FoxxMC'


result = FoxxMC::Scripts.rollback ROOT: "#{__dirname}/../../"


module.exports = result
