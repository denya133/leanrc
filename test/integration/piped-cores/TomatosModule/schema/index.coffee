# здесь мы подтягиваем основной модуль, наследуемся от него, объявляем миграции, объявляем команды, медиатор и прокси - подготавливаем модуль для работы в режиме инстанса апликейшена.

Tomatos = require '../lib'

class TomatosSchema extends Tomatos
  @inheritProtected()

  @root __dirname

  require('./migrations/BaseMigration') @Module

  require('./commands/PrepareControllerCommand') @Module
  require('./commands/PrepareViewCommand') @Module
  require('./commands/PrepareModelCommand') @Module
  require('./commands/StartupCommand') @Module
  # под вопросом - надо ли здесь объявлять команды migrate и rollback ???

  require('./mediators/ApplicationMediator') @Module

  require('./proxies/BaseCollection') @Module
  require('./proxies/BaseResque') @Module
  require('./proxies/MigrationsCollection') @Module

  require('./ApplicationFacade') @Module

  require('./SchemaApplication') @Module


module.exports = TomatosSchema.initialize().freeze()
