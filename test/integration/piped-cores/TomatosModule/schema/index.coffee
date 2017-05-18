# здесь мы подтягиваем основной модуль, наследуемся от него, объявляем миграции, объявляем команды, медиатор и прокси - подготавливаем модуль для работы в режиме инстанса апликейшена.

Tomatos = require '../lib'

class TomatosSchema extends Tomatos
  @inheritProtected()
  @include Tomatos::SchemaModuleMixin

  @root __dirname

  require.main.require('lib/patterns/command/MigrateCommand') @Module
  require.main.require('lib/patterns/command/RollbackCommand') @Module
  require('./migrations/BaseMigration') @Module

  @defineMigrations()

  require('./proxies/BaseCollection') @Module
  require('./proxies/BaseResque') @Module
  require('./proxies/MigrationsCollection') @Module

  require('./mediators/ApplicationMediator') @Module

  require('./commands/PrepareControllerCommand') @Module
  require('./commands/PrepareViewCommand') @Module
  require('./commands/PrepareModelCommand') @Module
  require('./commands/StartupCommand') @Module
  # под вопросом - надо ли здесь объявлять команды migrate и rollback ???

  require('./ApplicationFacade') @Module

  require('./SchemaApplication') @Module


module.exports = TomatosSchema.initialize().freeze()
