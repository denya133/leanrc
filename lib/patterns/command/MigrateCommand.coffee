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

  class MigrateCommand extends Module::SimpleCommand
    @inheritProtected()
    @include Module::ConfigurableMixin
    @module Module

    iplMigrationNames = @private migrationNames: Module::PromiseInterface

    @public migrationsCollection: Module::CollectionInterface
    @public migrationNames: Module::PromiseInterface,
      get: ->
        {co, filesList} = Module::Utils
        @[iplMigrationNames] ?= co =>
          files = yield filesList @migrationsDir
          yield return _.orderBy _.compact (files ? []).map (i)=>
            migrationName = i.replace /\.js|\.coffee/, ''
            if migrationName isnt 'BaseMigration'
              vsMigrationPath = "#{@migrationsDir}/#{migrationName}"
              require(vsMigrationPath) Module
              migrationName
            else
              null
        @[iplMigrationNames]

    @public migrationsDir: String,
      get: ->
        "#{@configs.ROOT}/compiled_migrations"

    @public init: Function,
      default: (args...)->
        @super args...
        @migrationsCollection = @facade.retriveProxy Module::MIGRATIONS
        return

    @public execute: Function,
      default: (options)->
        @migrate options
        return

    @public @async migrate: Function,
      args: []
      return: NILL
      default: (options)->
        migrationNames = yield @migrationNames
        for migrationName in migrationNames
          unless yield @migrationsCollection.includes migrationName
            id = String migrationName
            clearedMigrationName = migrationName.replace /^\d{14}[_]/, ''
            migrationClassName = inflect.camelize clearedMigrationName
            vcMigration = Module::[migrationClassName]
            try
              voMigration = vcMigration.new {id}, @migrationsCollection
              yield voMigration.migrate Module::Migration::UP
              yield voMigration.save()
            catch err
              error = "!!! Error in migration #{migrationName}"
              console.error error, err.message, err.stack
              break
          if options?.until? and options.until is migrationName
            break
        yield return


  MigrateCommand.initialize()
