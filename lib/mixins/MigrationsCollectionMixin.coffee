# этот файл будет подмешиваться к классу миграционной коллекции, который должен быть унаследован от LeanRC::Collection отдельно от остальных коллекций.
# collection должен найти все файлы миграций на жестком диске и прогрузить их в себя. (надо заиспользовать RC::Utils.filesList)
_             = require 'lodash'

###
```coffee
module.exports = (Module)->
  class MigrationsCollection extends Module::Collection
    @inheritProtected()
    @include Module::ArangoCollectionMixin
    @include Module::MigrationsCollectionMixin

    @Module: Module

  MigrationsCollection.initialize()
```

```coffee
module.exports = (Module)->
  {MIGRATIONS} = Module::

  class PrepareModelCommand extends Module::SimpleCommand
    @inheritProtected()

    @Module: Module

    @public execute: Function,
      default: ->
        #...
        @facade.registerProxy Module::MigrationsCollection.new MIGRATIONS
        #...

  PrepareModelCommand.initialize()
```
###

# !!! Коллекция должна быть зарегистрирована через Module::MIGRATIONS константу

module.exports = (Module)->
  {ANY, NILL} = Module::

  class MigrationsCollectionMixin extends Module::Mixin
    @inheritProtected()

    @Module: Module

    @public @async migrate: Function,
      args: []
      return: NILL
      default: ()->

    @public @async rollback: Function,
      args: []
      return: NILL
      default: ()->



  MigrationsCollectionMixin.initialize()
