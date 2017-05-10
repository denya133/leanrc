

LeanRC = require.main.require 'lib'


class CucumbersShell extends LeanRC
  @inheritProtected()

  @root __dirname

  require('./mediators/MainModuleMediator') @Module
  require('./mediators/LoggerModuleMediator') @Module
  require('./mediators/ShellJunctionMediator') @Module
  require('./mediators/ApplicationMediator') @Module

  require('./commands/PrepareViewCommand') @Module
  require('./commands/StartupCommand') @Module

  require('./ApplicationFacade') @Module

  require('./ShellApplication') @Module


module.exports = CucumbersShell.initialize().freeze()
