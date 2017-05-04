path = require 'path'
_ = require 'lodash'

###
http://edgeguides.rubyonrails.org/active_record_migrations.html
http://api.rubyonrails.org/
http://guides.rubyonrails.org/v3.2/migrations.html
http://rusrails.ru/rails-database-migrations
http://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html
###



###
```coffee
module.exports = (Module)->
  class BaseMigration extends Module::Migration
    @inheritProtected()
    @include Module::ArangoMigrationMixin # в этом миксине должны быть реализованы платформозависимые методы, которые будут посылать нативные запросы к реальной базе данных

    @module Module

  return BaseMigration.initialize()
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

```coffee
module.exports = (Module)->
  class CreateUsersCollectionMigration extends Module::BaseMigration
    @inheritProtected()
    @include Module::ArangoMigrationMixin # в этом миксине должны быть реализованы платформозависимые методы, которые будут посылать нативные запросы к реальной базе данных

    @module Module

    @up ->
      yield @createCollection 'users'
      yield @addField 'users', name, 'string'
      yield @addField 'users', description, 'text'
      yield @addField 'users', createdAt, 'date'
      yield @addField 'users', updatedAt, 'date'
      yield @addField 'users', deletedAt, 'date'
      yield return

    @down ->
      yield @dropCollection 'users'
      yield return

  return CreateUsersCollectionMigration.initialize()
```

Это эквивалентно

```coffee
module.exports = (Module)->
  class CreateUsersCollectionMigration extends Module::BaseMigration
    @inheritProtected()
    @include Module::ArangoMigrationMixin # в этом миксине должны быть реализованы платформозависимые методы, которые будут посылать нативные запросы к реальной базе данных

    @module Module

    @change ->
      @createCollection 'users'
      @addField 'users', name, 'string'
      @addField 'users', description, 'text'
      @addField 'users', createdAt, 'date'
      @addField 'users', updatedAt, 'date'
      @addField 'users', deletedAt, 'date'


  return CreateUsersCollectionMigration.initialize()
```
###

module.exports = (Module)->
  class Migration extends Module::Record
    @inheritProtected()
    @implements Module::MigrationInterface
    @module Module

    @const UP: Symbol 'UP'
    @const DOWN: Symbol 'DOWN'
    @const SUPPORTED_TYPES: {
      json:         Symbol 'json'
      binary:       Symbol 'binary'
      boolean:      Symbol 'boolean'
      date:         Symbol 'date'
      datetime:     Symbol 'datetime'
      decimal:      Symbol 'decimal'
      float:        Symbol 'float'
      integer:      Symbol 'integer'
      primary_key:  Symbol 'primary_key'
      string:       Symbol 'string'
      text:         Symbol 'text'
      time:         Symbol 'time'
      timestamp:    Symbol 'timestamp'
      array:        Symbol 'array'
      hash:         Symbol 'hash'
    }
    @const REVERSE_MAP:
      createCollection: 'dropCollection'
      dropCollection: 'createCollection'

      createEdgeCollection: 'dropEdgeCollection'
      dropEdgeCollection: 'createEdgeCollection'

      addField: 'removeField'
      removeField: 'addField'

      addIndex: 'removeIndex'
      removeIndex: 'addIndex'

      addTimestamps: 'removeTimestamps'
      removeTimestamps: 'addTimestamps'

      changeCollection: 'changeCollection'
      changeField: 'changeField'
      renameField: 'renameField'
      renameIndex: 'renameIndex'
      renameCollection: 'renameCollection'

    iplSteps = @private steps: Array

    @public steps: Array,
      get: -> Module::Utils.extend [], @[iplSteps] ? []

    # так же в рамках DSL нужны:
    # Creation
    #@createCollection #name, options, type # type is `document` or `edge`
    @public @static createCollection: Function,
      default: (args...)->
        @::[iplSteps] ?= []
        @::[iplSteps].push {args, method: 'createCollection'}
        return

    # @createEdgeCollection #для хранения связей М:М #collection_1, collection_2, options
    @public @static createEdgeCollection: Function,
      default: (args...)->
        @::[iplSteps] ?= []
        @::[iplSteps].push {args, method: 'createEdgeCollection'}
        return

    #@addField #collection_name, field_name, options #{type}
    @public @static addField: Function,
      default: (args...)->
        @::[iplSteps] ?= []
        @::[iplSteps].push {args, method: 'addField'}
        return

    #@addIndex #collection_name, field_names, options
    @public @static addIndex: Function,
      default: (args...)->
        @::[iplSteps] ?= []
        @::[iplSteps].push {args, method: 'addIndex'}
        return

    #@addTimestamps # создание полей createdAt, updatedAt, deletedAt #collection_name, options
    @public @static addTimestamps: Function,
      default: (args...)->
        @::[iplSteps] ?= []
        @::[iplSteps].push {args, method: 'addTimestamps'}
        return

    # Modification
    #@changeCollection #name, options
    @public @static changeCollection: Function,
      default: (args...)->
        @::[iplSteps] ?= []
        @::[iplSteps].push {args, method: 'changeCollection'}
        return

    #@changeField #collection_name, field_name, options #{type}
    @public @static changeField: Function,
      default: (args...)->
        @::[iplSteps] ?= []
        @::[iplSteps].push {args, method: 'changeField'}
        return

    #@renameField #collection_name, field_name, new_field_name
    @public @static renameField: Function,
      default: (args...)->
        @::[iplSteps] ?= []
        @::[iplSteps].push {args, method: 'renameField'}
        return

    #@renameIndex #collection_name, old_name, new_name
    @public @static renameIndex: Function,
      default: (args...)->
        @::[iplSteps] ?= []
        @::[iplSteps].push {args, method: 'renameIndex'}
        return

    #@renameCollection #collection_name, old_name, new_name
    @public @static renameCollection: Function,
      default: (args...)->
        @::[iplSteps] ?= []
        @::[iplSteps].push {args, method: 'renameCollection'}
        return

    #Deletion
    #@dropCollection #name
    @public @static dropCollection: Function,
      default: (args...)->
        @::[iplSteps] ?= []
        @::[iplSteps].push {args, method: 'dropCollection'}
        return

    # @dropEdgeCollection #collection_1, collection_2
    @public @static dropEdgeCollection: Function,
      default: (args...)->
        @::[iplSteps] ?= []
        @::[iplSteps].push {args, method: 'dropEdgeCollection'}
        return

    #@removeField #collection_name, field_name
    @public @static removeField: Function,
      default: (args...)->
        @::[iplSteps] ?= []
        @::[iplSteps].push {args, method: 'removeField'}
        return

    #@removeIndex #collection_name, field_names, options
    @public @static removeIndex: Function,
      default: (args...)->
        @::[iplSteps] ?= []
        @::[iplSteps].push {args, method: 'removeIndex'}
        return

    #@removeTimestamps # удаление полей createdAt, updatedAt, deletedAt #collection_name, options
    @public @static removeTimestamps: Function,
      default: (args...)->
        @::[iplSteps] ?= []
        @::[iplSteps].push {args, method: 'removeTimestamps'}
        return

    # Special
    # нужен для того, чтобы обернуть операцию изменения множества документов в удобном виде внутри `change` чтобы не писать много кода в up и down
    # пример использования:
    ###
    ```
      {wrap} = RC::Utils.co
      # без асинхронности - 'addField', 'reversible' и 'removeField' части DSL.
      # Они сохранят в метаданные все необходимое.
      # а реальный запускаемый код (автоматический или кастомынй)
      # будет в 'up' и 'down'
      @change ->
        @addField 'users', 'first_name', 'string'
        @addField 'users', 'last_name', 'string'

        @reversible wrap (dir)->
          UsersCollection = @collection.facade.retriveProxy 'UsersCollection'
          yield UsersCollection.forEach wrap (u)->
            yield dir.up   wrap ->
              [u.first_name, u.last_name] = u.full_name.split(' ')
              yield return
            yield dir.down wrap ->
              u.full_name = "#{u.first_name} #{u.last_name}"
              yield return
            yield u.save()
            yield return
          yield return

        @removeField 'users', 'full_name'
        return
    ```
    ###
    @public @static reversible: Function,
      default: (args...)->
        @::[iplSteps] ?= []
        @::[iplSteps].push {args, method: 'reversible'}
        return

    # Custom
    # будет выполняться функция содержащая платформозависимый код.
    # пример использования
    ###
    ```
      {wrap} = RC::Utils.co
      @up ->
        yield @execute wrap ->
          { db } = require '@arangodb'
          unless db._collection 'cucumbers'
            db._createDocumentCollection 'cucumbers', waitForSync: yes
          db._collection('cucumbers').ensureIndex
            type: 'hash'
            fields: ['_type']
          yield return
        yield return
      @down ->
        yield @execute wrap ->
          { db } = require '@arangodb'
          if db._collection 'cucumbers'
            db._drop 'cucumbers'
          yield return
        yield return
    ```
    ###
    @public @async execute: Function,
      default: (lambda)->
        yield lambda.apply @, []
        yield return

    # управляющие методы
    #@migrate #direction - переопределять не надо, тут главная точка вызова снаружи.
    @public @async migrate: Function,
      default: (direction)->
        switch direction
          when Migration::UP
            yield @up()
          when Migration::DOWN
            yield @down()
        yield return

    # если объявлена реализация метода `change`, то `up` и `down` объявлять не нужно (будут автоматически выдавать ответ на основе методанных объявленных в `change`)
    # использовать показанные выше DSL-методы надо именно в `change`
    @public @static change: Function,
      default: (lambda)->
        lambda.apply @, []
        return

    # с кодом Collections и Records объявленных в приложении надо работать именно в `up` и в `down`
    # асинхронные, потому что будут работать с базой данных возможно через I/O
    # здесь должна быть объявлена логика "автоматическая" - если вызов `change` создает метаданные, то заиспользовать эти метаданные для выполнения. Если метаданных нет, то скорее всего либо это пока еще пустая миграция без кода вообще, либо в унаследованном классе будут переопределны и `up` и `down`
    @public @async up: Function,
      default: ->
        steps = @[iplSteps]?[..] ? []
        yield Module::Utils.forEach steps, ({ method, args }) ->
          if method is 'reversible'
            [lambda] = args
            yield lambda.call @,
              up: (f)-> f()
              down: -> Module::Promise.resolve()
          else
            yield @[method] args...
        , @
        yield return

    @public @static up: Function,
      default: (lambda)->
        @public @async up: Function,
          default: lambda
        return

    @public @async down: Function,
      default: ->
        steps = @[iplSteps]?[..] ? []
        steps.reverse()
        yield Module::Utils.forEach steps, ({ method, args }) ->
          if method is 'reversible'
            [lambda] = args
            yield lambda.call @,
              up: -> Module::Promise.resolve()
              down: (f)-> f()
          else if _.includes [
            'renameField'
            'renameIndex'
            'renameCollection'
          ], method
            [collectionName, oldName, newName] = args
            yield @[method] collectionName, newName, oldName
          else
            yield @[Migration::REVERSE_MAP[method]] args...
        , @
        yield return

    @public @static down: Function,
      default: (lambda)->
        @public @async down: Function,
          default: lambda
        return


  Migration.initialize()
