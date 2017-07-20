# Это может быть сторонний модуль, который может подключаться как Cucumbers
LeanRC = require.main.require 'lib'

class CucumbersLogger extends LeanRC
  @inheritProtected()

  @root __dirname

  require('./mediators/LoggerJunctionMediator') @Module

  require('./proxies/LoggerProxy') @Module

  require('./commands/PrepareControllerCommand') @Module
  require('./commands/PrepareViewCommand') @Module
  require('./commands/PrepareModelCommand') @Module
  require('./commands/StartupCommand') @Module

  require('./ApplicationFacade') @Module

  require('./LoggerApplication') @Module


module.exports = CucumbersLogger.initialize().freeze()
