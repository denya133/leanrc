class TestApp

require('./AppConstants') TestApp

require('./controller/command/StartupCommand') TestApp
require('./controller/command/PrepareControllerCommand') TestApp
require('./controller/command/PrepareViewCommand') TestApp
require('./controller/command/PrepareModelCommand') TestApp
require('./controller/command/AnimateRobotCommand') TestApp

require('./view/component/ConsoleComponent') TestApp

require('./AppFacade') TestApp

module.exports = TestApp
