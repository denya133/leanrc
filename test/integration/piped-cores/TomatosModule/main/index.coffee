
Tomatos = require '../lib'

class TomatosMain extends Tomatos
  @inheritProtected()

  @root __dirname

  require('./commands/PrepareControllerCommand') @Module
  require('./commands/PrepareViewCommand') @Module
  require('./commands/PrepareModelCommand') @Module
  require('./commands/StartupCommand') @Module

  require('./mediators/MainJunctionMediator') @Module

  require('./proxies/BaseConfiguration') @Module
  require('./proxies/BaseCollection') @Module
  require('./proxies/BaseResque') @Module

  require('./ApplicationFacade') @Module

  require('./MainApplication') @Module


module.exports = TomatosMain.initialize().freeze()
