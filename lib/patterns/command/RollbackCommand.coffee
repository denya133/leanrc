# можно унаследовать от SimpleCommand
# внутри он должен обратиться к фасаду чтобы тот вернул ему 'MigrationsCollection'
# и уже у коллекции вызвать метод `rollback` - остальное ложится на плечи коллекции


module.exports = (Module) ->
  class RollbackCommand extends Module::SimpleCommand
    @inheritProtected()
    @module Module

    @public execute: Function,
      default: ->
        migrationsCollection = @facade.retriveProxy Module::MIGRATIONS
        migrationsCollection.rollback()
        return

  RollbackCommand.initialize()
