
Tomatos = require '../lib'

class TomatosCore extends Tomatos
  @inheritProtected()

  @root __dirname

  require('./commands/PrepareControllerCommand') @Module
  require('./commands/PrepareViewCommand') @Module
  require('./commands/PrepareModelCommand') @Module
  require('./commands/StartupCommand') @Module

  require('./mediators/CoreJunctionMediator') @Module

  require('./proxies/BaseConfiguration') @Module
  require('./proxies/BaseCollection') @Module
  require('./proxies/BaseResque') @Module

  require('./ApplicationFacade') @Module

  require('./CoreApplication') @Module


module.exports = TomatosCore.initialize().freeze()
