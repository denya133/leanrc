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
  {ANY, NILL} = Module::

  class RollbackCommand extends Module::SimpleCommand
    @inheritProtected()
    @include Module::ConfigurableMixin
    @module Module

    @public migrationsCollection: Module::CollectionInterface
    @public migrationNames: Module::PromiseInterface,
      get: ->
        {co, filesList} = Module::Utils
        @[iplMigrationNames] ?= co =>
          files = yield filesList @migrationsDir
          yield return _.orderBy (files ? []).map (i)=>
            migrationName = i.replace '.js', ''
            vsMigrationPath = "#{@migrationsDir}/#{migrationName}"
            require(vsMigrationPath) Module
            migrationName
        @[iplMigrationNames]

    @public migrationsDir: String,
      get: ->
        "#{@Module::ROOT}/compiled_migrations"

    @public init: Function,
      default: (args...)->
        @super args...
        @migrationsCollection = @facade.retriveProxy Module::MIGRATIONS
        return

    @public execute: Function,
      default: (options)->
        @rollback options
        return

    @public @async rollback: Function,
      args: []
      return: NILL
      default: (options)->
        if options?.steps? and not _.isNumber options.steps
          throw new Error 'Not valid steps params'
          yield return

        yield @migrationNames

        executedMigrations = (yield @migrationsCollection.takeAll()).toArray()
        executedMigrations = _.orderBy executedMigrations, ['id', 'desc']
        executedMigrations = executedMigrations[0...(options.steps ? 1)]

        for executedMigration in executedMigrations
          try
            clearedMigrationName = executedMigration.replace /^\d{14}[_]/, ''
            migrationClassName = inflect.camelize clearedMigrationName
            vcMigration = Module::[migrationClassName]
            voMigration = vcMigration.new {}, @migrationsCollection
            yield voMigration.migrate Module::Migration::DOWN
            yield voMigration.destroy()
          catch err
            error = "!!! Error in migration #{executedMigration}"
            console.error error, err.message, err.stack
            break
          if options?.until? and options.until is migrationName
            break
        yield return


  RollbackCommand.initialize()
