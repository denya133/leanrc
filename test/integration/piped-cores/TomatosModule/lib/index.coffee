

LeanRC = require.main.require 'lib'


class Tomatos extends LeanRC
  @inheritProtected()
  @include LeanRC::SchemaModuleMixin

  @root __dirname

  Utils: LeanRC::Utils.assign {}, LeanRC::Utils

  require('LeanRC/dist/patterns/command/MigrateCommand') @Module
  require('LeanRC/dist/patterns/command/RollbackCommand') @Module
  require('LeanRC/dist/patterns/command/DelayedJobScript') @Module

  require('./serializers/ApplicationSerializer') @Module
  require('./serializers/HttpSerializer') @Module

  require('./records/TomatoRecord') @Module
  require('./records/CucumberRecord') @Module

  require('./migrations/BaseMigration') @Module
  @defineMigrations()

  require('./resources/TomatosResource') @Module

  require('./ApplicationRouter') @Module

  require('./mediators/MainSwitch') @Module
  require('./mediators/ResqueExecutor') @Module
  require('./mediators/LoggerModuleMediator') @Module
  require('./mediators/ShellJunctionMediator') @Module
  require('./mediators/ApplicationMediator') @Module

  require('./proxies/MainConfiguration') @Module
  require('./proxies/ThinHttpCollection') @Module
  require('./proxies/MainCollection') @Module
  require('./proxies/MainResque') @Module
  require('./proxies/MigrationsCollection') @Module
  require('./proxies/ApplicationGateway') @Module

  require('./commands/PrepareControllerCommand') @Module
  require('./commands/PrepareViewCommand') @Module
  require('./commands/PrepareModelCommand') @Module
  require('./commands/StartupCommand') @Module

  require('./ApplicationFacade') @Module

  require('./MainApplication') @Module


module.exports = Tomatos.initialize().freeze()
