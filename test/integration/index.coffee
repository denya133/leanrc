class TestApp

require('./AppConstants') TestApp

require('./controller/command/StartupCommand') TestApp
require('./controller/command/PrepareControllerCommand') TestApp

require('./AppFacade') TestApp

module.exports = TestApp
