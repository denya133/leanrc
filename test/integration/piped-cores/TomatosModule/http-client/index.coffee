
Tomatos = require '../lib'

class TomatosHttpClient extends Tomatos
  @inheritProtected()

  @root __dirname

  require('./commands/PrepareControllerCommand') @Module
  require('./commands/PrepareViewCommand') @Module
  require('./commands/PrepareModelCommand') @Module
  require('./commands/StartupCommand') @Module

  require('./mediators/HttpClientJunctionMediator') @Module

  require('./proxies/BaseConfiguration') @Module
  require('./proxies/BaseResource') @Module


  require('./ApplicationFacade') @Module

  require('./HttpClientApplication') @Module


module.exports = TomatosHttpClient.initialize().freeze()
