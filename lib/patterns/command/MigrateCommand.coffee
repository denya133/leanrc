# можно унаследовать от SimpleCommand
# внутри он должен обратиться к фасаду чтобы тот вернул ему 'MigrationsCollection'
# и уже у коллекции вызвать метод 'migrate' - остальное ложится на плечи коллекции


module.exports = (Module) ->
  class MigrateCommand extends Module::SimpleCommand
    @inheritProtected()
    @Module: Module

    @public execute: Function,
      default: ->
        migrationsCollection = @facade.retriveProxy Module::MIGRATIONS
        migrationsCollection.migrate()
        return


  MigrateCommand.initialize()
