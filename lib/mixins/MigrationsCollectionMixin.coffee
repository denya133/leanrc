# этот файл будет подмешиваться к классу миграционной коллекции, который должен быть унаследован от LeanRC::Collection отдельно от остальных коллекций.
# collection должен найти все файлы миграций на жестком диске и прогрузить их в себя. (надо заиспользовать RC::Utils.filesList)
_             = require 'lodash'
inflect       = do require 'i'


###
```coffee
module.exports = (Module)->
  class MigrationsCollection extends Module::Collection
    @inheritProtected()
    @include Module::ArangoCollectionMixin
    @include Module::MigrationsCollectionMixin

    @module Module

  MigrationsCollection.initialize()
```

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
        @facade.registerProxy Module::MigrationsCollection.new MIGRATIONS,
          delegate: Module::BaseMigration
        #...

  PrepareModelCommand.initialize()
```
###

# !!! Коллекция должна быть зарегистрирована через Module::MIGRATIONS константу

module.exports = (Module)->
  {ANY, NILL} = Module::

  class MigrationsCollectionMixin extends Module::Mixin
    @inheritProtected()

    @module Module

    @public migrationNames: Array

    @public migrationsDir: String,
      get: ->
        "#{@Module::ROOT}/compiled_migrations"

    @public onRegister: Function,
      default: (args...)->
        @super args...
        @migrationNames = _.orderBy fs.list(@migrationsDir).map (i)=>
          migrationName = i.replace '.js', ''
          vsMigrationPath = "#{@migrationsDir}/#{migrationName}"
          require(vsMigrationPath) Module
          migrationName
        return

    @public @async migrate: Function,
      args: []
      return: NILL
      default: (options)->
        for migrationName in @migrationNames
          unless yield @includes migrationName
            clearedMigrationName = migrationName.replace /^\d{14}[_]/, ''
            migrationClassName = inflect.camelize clearedMigrationName
            vcMigration = Module::[migrationClassName]
            try
              voMigration = vcMigration.new {}, @
              yield voMigration.migrate Module::Migration::UP
              yield voMigration.save()
            catch err
              error = "!!! Error in migration #{migrationName}"
              console.error error, err.message, err.stack
              break
          if options?.until? and options.until is migrationName
            break
        yield return

    @public @async rollback: Function,
      args: []
      return: NILL
      default: (options)->
        if options?.steps? and not _.isNumber options.steps
          throw new Error 'Not valid steps params'
          yield return

        executedMigrations = yield @query {
          $forIn: '@doc': @collectionName()
          $sort: ['@doc._key': 'DESC']
          $limit: options.steps ? 1
        }
          .toArray()

        for executedMigration in executedMigrations
          try
            clearedMigrationName = executedMigration.replace /^\d{14}[_]/, ''
            migrationClassName = inflect.camelize clearedMigrationName
            vcMigration = Module::[migrationClassName]
            voMigration = vcMigration.new {}, @
            yield voMigration.migrate Module::Migration::DOWN
            yield voMigration.destroy()
          catch err
            error = "!!! Error in migration #{executedMigration}"
            console.error error, err.message, err.stack
            break
          if options?.until? and options.until is migrationName
            break
        yield return


  MigrationsCollectionMixin.initialize()
