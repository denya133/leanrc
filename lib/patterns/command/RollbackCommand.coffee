# можно унаследовать от SimpleCommand
# внутри он должен обратиться к фасаду чтобы тот вернул ему 'MigrationsCollection'


###
```coffee
module.exports = (Module)->
  {MIGRATIONS} = Module::

  class BaseMigration extends Module::Migration
    @inheritProtected()
    @include Module::ArangoMigrationMixin

    @module Module

  BaseMigration.initialize()
```

```coffee
module.exports = (Module)->
  {MIGRATIONS} = Module::

  class PrepareModelCommand extends Module::SimpleCommand
    @inheritProtected()

    @module Module

    @public execute: Function,
      default: ->
        #...
        @facade.registerProxy Module::BaseCollection.new MIGRATIONS,
          delegate: Module::BaseMigration
        #...

  PrepareModelCommand.initialize()
```
###

# !!! Коллекция должна быть зарегистрирована через Module::MIGRATIONS константу


module.exports = (Module) ->
  {
    APPLICATION_MEDIATOR
    STOPPED_ROLLBACK
    NilT
    FuncG, ListG, MaybeG, StructG, UnionG
    NotificationInterface, CollectionInterface
    ConfigurableMixin
    SimpleCommand
    Utils: { _, inflect }
  } = Module::

  class RollbackCommand extends SimpleCommand
    @inheritProtected()
    @include ConfigurableMixin
    @module Module

    @public migrationsCollection: CollectionInterface
    @public migrationNames: ListG(String),
      get: ->
        app = @facade.retrieveMediator APPLICATION_MEDIATOR
          .getViewComponent()
        app.Module::MIGRATION_NAMES ? []

    @public migrationsDir: String,
      get: ->
        "#{@configs.ROOT}/migrations"

    @public initializeNotifier: FuncG(String, NilT),
      default: (args...)->
        @super args...
        @migrationsCollection = @facade.retrieveProxy Module::MIGRATIONS
        return

    @public @async execute: FuncG(NotificationInterface, NilT),
      default: (aoNotification)->
        voBody = aoNotification.getBody()
        vsType = aoNotification.getType()
        err = yield @rollback voBody ? {}
        @facade.sendNotification STOPPED_ROLLBACK, {error: err}, vsType
        yield return

    @public @async rollback: FuncG([MaybeG StructG steps: MaybeG(Number), until: MaybeG String], UnionG NilT, Error),
      default: (options)->
        if options?.steps? and not _.isNumber options.steps
          throw new Error 'Not valid steps params'
          yield return

        executedMigrations = yield (yield @migrationsCollection.takeAll()).toArray()
        executedMigrations = _.orderBy executedMigrations, ['id'], ['desc']
        executedMigrations = executedMigrations[0...(options.steps ? 1)]

        for executedMigration in executedMigrations
          try
            yield executedMigration.migrate Module::Migration::DOWN
            yield executedMigration.destroy()
          catch err
            error = "!!! Error in migration #{executedMigration}"
            console.error error, err.message, err.stack
            break
          if options?.until? and options.until is executedMigration.id
            break
        yield return err


    @initialize()
