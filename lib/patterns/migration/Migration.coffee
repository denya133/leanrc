

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
  {
    AnyT, NilT, AsyncFunctionT, PointerT
    FuncG, ListG, StructG, EnumG, MaybeG, UnionG, InterfaceG, AsyncFuncG, SubsetG
    MigrationInterface, RecordInterface
    Record
    Utils: { _, forEach, assign, co }
  } = Module::

  class Migration extends Record
    @inheritProtected()
    @implements MigrationInterface
    @module Module

    { UP, DOWN, SUPPORTED_TYPES } = @::

    # @const UP: UP = Symbol 'UP'
    # @const DOWN: DOWN = Symbol 'DOWN'
    # @const SUPPORTED_TYPES: SUPPORTED_TYPES = {
    #   json:         'json'
    #   binary:       'binary'
    #   boolean:      'boolean'
    #   date:         'date'
    #   datetime:     'datetime'
    #   number:       'number'
    #   decimal:      'decimal'
    #   float:        'float'
    #   integer:      'integer'
    #   primary_key:  'primary_key'
    #   string:       'string'
    #   text:         'text'
    #   time:         'time'
    #   timestamp:    'timestamp'
    #   array:        'array'
    #   hash:         'hash'
    # }
    @const REVERSE_MAP: REVERSE_MAP = {
      createCollection: 'dropCollection'
      dropCollection: 'dropCollection'

      createEdgeCollection: 'dropEdgeCollection'
      dropEdgeCollection: 'dropEdgeCollection'

      addField: 'removeField'
      removeField: 'removeField'

      addIndex: 'removeIndex'
      removeIndex: 'removeIndex'

      addTimestamps: 'removeTimestamps'
      removeTimestamps: 'addTimestamps'

      changeCollection: 'changeCollection'
      changeField: 'changeField'
      renameField: 'renameField'
      renameIndex: 'renameIndex'
      renameCollection: 'renameCollection'
    }
    iplSteps = PointerT @private steps: MaybeG ListG StructG {
      args: Array
      method: EnumG [
        'createCollection'
        'createEdgeCollection'
        'addField'
        'addIndex'
        'addTimestamps'
        'changeCollection'
        'changeField'
        'renameField'
        'renameIndex'
        'renameCollection'
        'dropCollection'
        'dropEdgeCollection'
        'removeField'
        'removeIndex'
        'removeTimestamps'
        'reversible'
      ]
    }

    @public steps: ListG(StructG {
      args: Array
      method: EnumG [
        'createCollection'
        'createEdgeCollection'
        'addField'
        'addIndex'
        'addTimestamps'
        'changeCollection'
        'changeField'
        'renameField'
        'renameIndex'
        'renameCollection'
        'dropCollection'
        'dropEdgeCollection'
        'removeField'
        'removeIndex'
        'removeTimestamps'
        'reversible'
      ]
    }),
      get: -> assign [], @[iplSteps] ? []

    # так же в рамках DSL нужны:
    # Creation
    #@createCollection #name, options
    @public @static createCollection: FuncG([String, MaybeG Object]),
      default: (args...)->
        @::[iplSteps].push {args, method: 'createCollection'}
        return

    @public @async createCollection: FuncG([String, MaybeG Object]),
      default: ->
        throw new Error 'Not implemented specific method'
        yield return

    # @createEdgeCollection #для хранения связей М:М #collection_1, collection_2, options
    @public @static createEdgeCollection: FuncG([String, String, MaybeG Object]),
      default: (args...)->
        @::[iplSteps].push {args, method: 'createEdgeCollection'}
        return

    @public @async createEdgeCollection: FuncG([String, String, MaybeG Object]),
      default: ->
        throw new Error 'Not implemented specific method'
        yield return

    #@addField #collection_name, field_name, options #{type}
    @public @static addField: FuncG([String, String, UnionG(
      EnumG SUPPORTED_TYPES
      InterfaceG {
        type: EnumG SUPPORTED_TYPES
        default: AnyT
      }
    )]),
      default: (args...)->
        @::[iplSteps].push {args, method: 'addField'}
        return

    @public @async addField: FuncG([String, String, UnionG(
      EnumG SUPPORTED_TYPES
      InterfaceG {
        type: EnumG SUPPORTED_TYPES
        default: AnyT
      }
    )]),
      default: ->
        throw new Error 'Not implemented specific method'
        yield return

    #@addIndex #collection_name, field_names, options
    @public @static addIndex: FuncG([String, ListG(String), InterfaceG {
      type: EnumG 'hash', 'skiplist', 'persistent', 'geo', 'fulltext'
      unique: MaybeG Boolean
      sparse: MaybeG Boolean
    }]),
      default: (args...)->
        @::[iplSteps].push {args, method: 'addIndex'}
        return

    @public @async addIndex: FuncG([String, ListG(String), InterfaceG {
      type: EnumG 'hash', 'skiplist', 'persistent', 'geo', 'fulltext'
      unique: MaybeG Boolean
      sparse: MaybeG Boolean
    }]),
      default: ->
        throw new Error 'Not implemented specific method'
        yield return

    #@addTimestamps # создание полей createdAt, updatedAt, deletedAt #collection_name, options
    @public @static addTimestamps: FuncG([String, MaybeG Object]),
      default: (args...)->
        @::[iplSteps].push {args, method: 'addTimestamps'}
        return

    @public @async addTimestamps: FuncG([String, MaybeG Object]),
      default: ->
        throw new Error 'Not implemented specific method'
        yield return

    # Modification
    #@changeCollection #name, options
    @public @static changeCollection: FuncG([String, Object]),
      default: (args...)->
        @::[iplSteps].push {args, method: 'changeCollection'}
        return

    @public @async changeCollection: FuncG([String, Object]),
      default: ->
        throw new Error 'Not implemented specific method'
        yield return

    #@changeField #collection_name, field_name, options #{type}
    @public @static changeField: FuncG([String, String, UnionG(
      EnumG SUPPORTED_TYPES
      InterfaceG {
        type: EnumG SUPPORTED_TYPES
      }
    )]),
      default: (args...)->
        @::[iplSteps].push {args, method: 'changeField'}
        return

    @public @async changeField: FuncG([String, String, UnionG(
      EnumG SUPPORTED_TYPES
      InterfaceG {
        type: EnumG SUPPORTED_TYPES
      }
    )]),
      default: ->
        throw new Error 'Not implemented specific method'
        yield return

    #@renameField #collection_name, field_name, new_field_name
    @public @static renameField: FuncG([String, String, String]),
      default: (args...)->
        @::[iplSteps].push {args, method: 'renameField'}
        return

    @public @async renameField: FuncG([String, String, String]),
      default: ->
        throw new Error 'Not implemented specific method'
        yield return

    #@renameIndex #collection_name, old_name, new_name
    @public @static renameIndex: FuncG([String, String, String]),
      default: (args...)->
        @::[iplSteps].push {args, method: 'renameIndex'}
        return

    @public @async renameIndex: FuncG([String, String, String]),
      default: ->
        throw new Error 'Not implemented specific method'
        yield return

    #@renameCollection #collection_name, old_name, new_name
    @public @static renameCollection: FuncG([String, String]),
      default: (args...)->
        @::[iplSteps].push {args, method: 'renameCollection'}
        return

    @public @async renameCollection: FuncG([String, String]),
      default: ->
        throw new Error 'Not implemented specific method'
        yield return

    #Deletion
    #@dropCollection #name
    @public @static dropCollection: FuncG(String),
      default: (args...)->
        @::[iplSteps].push {args, method: 'dropCollection'}
        return

    @public @async dropCollection: FuncG(String),
      default: ->
        throw new Error 'Not implemented specific method'
        yield return

    # @dropEdgeCollection #collection_1, collection_2
    @public @static dropEdgeCollection: FuncG([String, String]),
      default: (args...)->
        @::[iplSteps].push {args, method: 'dropEdgeCollection'}
        return

    @public @async dropEdgeCollection: FuncG([String, String]),
      default: ->
        throw new Error 'Not implemented specific method'
        yield return

    #@removeField #collection_name, field_name
    @public @static removeField: FuncG([String, String]),
      default: (args...)->
        @::[iplSteps].push {args, method: 'removeField'}
        return

    @public @async removeField: FuncG([String, String]),
      default: ->
        throw new Error 'Not implemented specific method'
        yield return

    #@removeIndex #collection_name, field_names, options
    @public @static removeIndex: FuncG([String, ListG(String), InterfaceG {
      type: EnumG 'hash', 'skiplist', 'persistent', 'geo', 'fulltext'
      unique: MaybeG Boolean
      sparse: MaybeG Boolean
    }]),
      default: (args...)->
        @::[iplSteps].push {args, method: 'removeIndex'}
        return

    @public @async removeIndex: FuncG([String, ListG(String), InterfaceG {
      type: EnumG 'hash', 'skiplist', 'persistent', 'geo', 'fulltext'
      unique: MaybeG Boolean
      sparse: MaybeG Boolean
    }]),
      default: ->
        throw new Error 'Not implemented specific method'
        yield return

    #@removeTimestamps # удаление полей createdAt, updatedAt, deletedAt #collection_name, options
    @public @static removeTimestamps: FuncG([String, MaybeG Object]),
      default: (args...)->
        @::[iplSteps].push {args, method: 'removeTimestamps'}
        return

    @public @async removeTimestamps: FuncG([String, MaybeG Object]),
      default: ->
        throw new Error 'Not implemented specific method'
        yield return

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
          UsersCollection = @collection.facade.retrieveProxy USERS
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
    @public @static reversible: FuncG(AsyncFuncG(
      StructG {
        up: AsyncFuncG AsyncFunctionT
        down: AsyncFuncG AsyncFunctionT
      }
    )),
      default: (args...)->
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
            fields: ['type']
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
    @public @async execute: FuncG(AsyncFunctionT),
      default: (lambda)->
        yield lambda.apply @, []
        yield return

    # управляющие методы
    #@migrate #direction - переопределять не надо, тут главная точка вызова снаружи.
    @public @async migrate: FuncG([EnumG UP, DOWN]),
      default: (direction)->
        switch direction
          when UP
            yield @up()
          when DOWN
            yield @down()
        yield return

    # если объявлена реализация метода `change`, то `up` и `down` объявлять не нужно (будут автоматически выдавать ответ на основе методанных объявленных в `change`)
    # использовать показанные выше DSL-методы надо именно в `change`
    @public @static change: FuncG(Function),
      default: (lambda)->
        @::[iplSteps] ?= []
        lambda.apply @, []
        return

    # с кодом Collections и Records объявленных в приложении надо работать именно в `up` и в `down`
    # асинхронные, потому что будут работать с базой данных возможно через I/O
    # здесь должна быть объявлена логика "автоматическая" - если вызов `change` создает метаданные, то заиспользовать эти метаданные для выполнения. Если метаданных нет, то скорее всего либо это пока еще пустая миграция без кода вообще, либо в унаследованном классе будут переопределны и `up` и `down`
    @public @async up: Function,
      default: ->
        steps = @[iplSteps]?[..] ? []
        yield forEach steps, ({ method, args }) ->
          if method is 'reversible'
            [lambda] = args
            yield lambda.call @,
              up: co.wrap (f)-> return yield f()
              down: co.wrap -> return yield Module::Promise.resolve()
          else
            yield @[method] args...
        , @
        yield return

    @public @static up: FuncG(AsyncFunctionT),
      default: (lambda)->
        @::[iplSteps] ?= []
        @public @async up: AsyncFunctionT,
          default: lambda
        return

    @public @async down: Function,
      default: ->
        steps = @[iplSteps]?[..] ? []
        steps.reverse()
        yield forEach steps, ({ method, args }) ->
          if method is 'reversible'
            [lambda] = args
            yield lambda.call @,
              up: co.wrap -> return yield Module::Promise.resolve()
              down: co.wrap (f)-> return yield f()
          else if _.includes [
            'renameField'
            'renameIndex'
          ], method
            [collectionName, oldName, newName] = args
            yield @[method] collectionName, newName, oldName
          else if method is 'renameCollection'
            [collectionName, newName] = args
            yield @[method] newName, collectionName
          else
            yield @[REVERSE_MAP[method]] args...
        , @
        yield return

    @public @static down: FuncG(AsyncFunctionT),
      default: (lambda)->
        @::[iplSteps] ?= []
        @public @async down: AsyncFunctionT,
          default: lambda
        return

    @public @static @async restoreObject: FuncG([SubsetG(Module), Object], RecordInterface),
      default: ->
        throw new Error "restoreObject method not supported for #{@name}"
        yield return

    @public @static @async replicateObject: FuncG(RecordInterface, Object),
      default: ->
        throw new Error "replicateObject method not supported for #{@name}"
        yield return


    @initialize()
