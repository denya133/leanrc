# Это может быть сторонний модуль, который может подключаться как Cucumbers
LeanRC = require.main.require 'lib'

class Logger extends LeanRC
  @inheritProtected()

  @root __dirname

  require('./commands/PrepareControllerCommand') @Module
  require('./commands/PrepareViewCommand') @Module
  require('./commands/PrepareModelCommand') @Module
  require('./commands/StartupCommand') @Module

  require('./mediators/LoggerJunctionMediator') @Module

  require('./proxies/LoggerProxy') @Module

  require('./ApplicationFacade') @Module

  require('./LoggerApplication') @Module


module.exports = Logger.initialize().freeze()
