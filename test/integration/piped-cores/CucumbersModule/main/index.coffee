
Cucumbers = require '../lib'

class CucumbersMain extends Cucumbers
  @inheritProtected()

  @root __dirname

  @const TEST_PROXY_NAME: 'TEST_PROXY_NAME'

  require.main.require('lib/patterns/command/DelayedJobScript') @Module
  require('./mediators/ResqueExecutor') @Module
  require('./mediators/MainJunctionMediator') @Module
  require('./mediators/MainSwitch') @Module
  require('./mediators/ApplicationMediator') @Module

  require('./proxies/MainCollection') @Module
  require('./proxies/MainResque') @Module
  require('./proxies/TestProxy') @Module

  require('./commands/TestScript') @Module
  require('./commands/PrepareControllerCommand') @Module
  require('./commands/PrepareViewCommand') @Module
  require('./commands/PrepareModelCommand') @Module
  require('./commands/StartupCommand') @Module

  require('./ApplicationFacade') @Module

  require('./MainApplication') @Module


module.exports = CucumbersMain.initialize().freeze()
