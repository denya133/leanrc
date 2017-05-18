# можно унаследовать от SimpleCommand
# внутри он должен обратиться к фасаду чтобы тот вернул ему 'MigrationsCollection'

_             = require 'lodash'
inflect       = do require 'i'


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
  {ANY, NILL, STOPPED_MIGRATE} = Module::

  class MigrateCommand extends Module::SimpleCommand
    @inheritProtected()
    @include Module::ConfigurableMixin
    @module Module

    @public migrationsCollection: Module::CollectionInterface
    @public migrationNames: Module::PromiseInterface,
      get: -> @Module::MIGRATION_NAMES ? []

    @public migrationsDir: String,
      get: ->
        "#{@configs.ROOT}/migrations"

    @public initializeNotifier: Function,
      default: (args...)->
        @super args...
        @migrationsCollection = @facade.retrieveProxy Module::MIGRATIONS
        return

    @public execute: Function,
      default: (options)->
        @migrate options
        return

    @public @async migrate: Function,
      args: []
      return: NILL
      default: (options)->
        if options instanceof Module::Notification
          options = options.getBody() ? {}
        for migrationName in @migrationNames
          unless yield @migrationsCollection.includes migrationName
            id = String migrationName
            clearedMigrationName = migrationName.replace /^\d{14}[_]/, ''
            migrationClassName = inflect.camelize clearedMigrationName
            vcMigration = @Module::[migrationClassName]
            type = "#{@Module.name}::#{migrationClassName}"
            try
              voMigration = yield @migrationsCollection.find id
              unless voMigration?
                voMigration = vcMigration.new { id, type }, @migrationsCollection
                yield voMigration.migrate Module::Migration::UP
                yield voMigration.save()
            catch err
              error = "!!! Error in migration #{migrationName}"
              console.error error, err.message, err.stack
              break
          if options?.until? and options.until is migrationName
            break
        @facade.sendNotification STOPPED_MIGRATE, err
        yield return


  MigrateCommand.initialize()
