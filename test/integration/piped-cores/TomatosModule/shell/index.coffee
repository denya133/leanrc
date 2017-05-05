

LeanRC = require.main.require 'lib'


class TomatosShell extends LeanRC
  @inheritProtected()

  @root __dirname

  require('./commands/PrepareViewCommand') @Module
  require('./commands/StartupCommand') @Module

  require('./mediators/MainModuleMediator') @Module
  require('./mediators/CucumbersModuleMediator') @Module
  require('./mediators/ShellJunctionMediator') @Module
  require('./mediators/ApplicationMediator') @Module

  require('./ApplicationFacade') @Module

  require('./ShellApplication') @Module


module.exports = TomatosShell.initialize().freeze()
