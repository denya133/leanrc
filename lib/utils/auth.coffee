createAuth = require '@arangodb/foxx/auth'
FoxxMC::Utils.auth = createAuth()


module.exports = FoxxMC::Utils.auth
