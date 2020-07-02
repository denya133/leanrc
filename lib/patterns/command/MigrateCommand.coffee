# This file is part of LeanRC.
#
# LeanRC is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# LeanRC is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with LeanRC.  If not, see <https://www.gnu.org/licenses/>.

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
    STOPPED_MIGRATE
    NilT
    FuncG, ListG, MaybeG, StructG, UnionG
    NotificationInterface, CollectionInterface
    ConfigurableMixin
    SimpleCommand
    Utils: { _, inflect }
  } = Module::

  class MigrateCommand extends SimpleCommand
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

    @public initializeNotifier: FuncG(String),
      default: (args...)->
        @super args...
        @migrationsCollection = @facade.retrieveProxy Module::MIGRATIONS
        return

    @public @async execute: FuncG(NotificationInterface),
      default: (aoNotification)->
        voBody = aoNotification.getBody()
        vsType = aoNotification.getType()
        err = yield @migrate voBody ? {}
        @facade.sendNotification STOPPED_MIGRATE, {error: err}, vsType
        yield return

    @public @async migrate: FuncG([MaybeG StructG until: MaybeG String], UnionG NilT, Error),
      default: (options)->
        app = @facade.retrieveMediator APPLICATION_MEDIATOR
          .getViewComponent()
        for migrationName in @migrationNames
          unless yield @migrationsCollection.includes migrationName
            id = String migrationName
            clearedMigrationName = migrationName.replace /^\d{14}[_]/, ''
            migrationClassName = inflect.camelize clearedMigrationName
            vcMigration = app.Module::[migrationClassName]
            type = "#{app.Module.name}::#{migrationClassName}"
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
        yield return err


    @initialize()
