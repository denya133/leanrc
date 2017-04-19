# надо унаследовать от SimpleCommand
path = require 'path'

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
  class CreateUsersCollectionMigration extends Module::Migration
    @inheritProtected()
    @include ArangoExtension::ArangoMigrationMixin # в этом миксине должны быть реализованы платформозависимые методы, которые будут посылать нативные запросы к реальной базе данных

    @Module: Module

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
  class CreateUsersCollectionMigration extends Module::Migration
    @inheritProtected()
    @include ArangoExtension::ArangoMigrationMixin # в этом миксине должны быть реализованы платформозависимые методы, которые будут посылать нативные запросы к реальной базе данных

    @Module: Module

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

    @Module: Module

    @const UP: Symbol 'UP'
    @const DOWN: Symbol 'DOWN'
    @const SUPPORTED_TYPES: [
      'json'
      'binary'
      'boolean'
      'date'
      'datetime'
      'decimal'
      'float'
      'integer'
      'primary_key'
      'string'
      'text'
      'time'
      'timestamp'
    ]
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

    @attr name: String

    iplSteps = @private steps: Array

    # так же в рамках DSL нужны:
    # Creation
    #@createCollection #name, options, type # type is `document` or `edge`
    @public @async @virtual createCollection: Function, # это должно быть реализовано в миксине с платформозависимым кодом
      args: [String, Object]
      return: Module::ANY
    @public @static createCollection: Function,
      args: [String, Object]
      return: Module::NILL
      default: (args...)->
        @::[iplSteps] ?= []
        @::[iplSteps].push {args, method: 'createCollection'}
        return

    # @createEdgeCollection #для хранения связей М:М #collection_1, collection_2, options
    @public @async @virtual createEdgeCollection: Function, # это должно быть реализовано в миксине с платформозависимым кодом
      args: [String, String, Object]
      return: Module::ANY
    @public @static createEdgeCollection: Function,
      args: [String, String, Object]
      return: Module::NILL
      default: (args...)->
        @::[iplSteps] ?= []
        @::[iplSteps].push {args, method: 'createEdgeCollection'}
        return

    #@addField #collection_name, field_name, options #{type}
    @public @async @virtual addField: Function, # это должно быть реализовано в миксине с платформозависимым кодом
      args: [String, String, Object]
      return: Module::ANY
    @public @static addField: Function,
      args: [String, String, Object]
      return: Module::NILL
      default: (args...)->
        @::[iplSteps] ?= []
        @::[iplSteps].push {args, method: 'addField'}
        return

    #@addIndex #collection_name, field_names, options
    @public @async @virtual addIndex: Function, # это должно быть реализовано в миксине с платформозависимым кодом
      args: [String, Array, Object]
      return: Module::ANY
    @public @static addIndex: Function,
      args: [String, Array, Object]
      return: Module::NILL
      default: (args...)->
        @::[iplSteps] ?= []
        @::[iplSteps].push {args, method: 'addIndex'}
        return

    #@addTimestamps # создание полей createdAt, updatedAt, deletedAt #collection_name, options
    @public @async @virtual addTimestamps: Function, # это должно быть реализовано в миксине с платформозависимым кодом
      args: [String, Object]
      return: Module::ANY
    @public @static addTimestamps: Function,
      args: [String, Object]
      return: Module::NILL
      default: (args...)->
        @::[iplSteps] ?= []
        @::[iplSteps].push {args, method: 'addTimestamps'}
        return

    # Modification
    #@changeCollection #name, options
    @public @async @virtual changeCollection: Function, # это должно быть реализовано в миксине с платформозависимым кодом
      args: [String, Object]
      return: Module::ANY
    @public @static changeCollection: Function,
      args: [String, Object]
      return: Module::NILL
      default: (args...)->
        @::[iplSteps] ?= []
        @::[iplSteps].push {args, method: 'changeCollection'}
        return

    #@changeField #collection_name, field_name, options #{type}
    @public @async @virtual changeField: Function, # это должно быть реализовано в миксине с платформозависимым кодом
      args: [String, String, Object]
      return: Module::ANY
    @public @static changeField: Function,
      args: [String, String, Object]
      return: Module::NILL
      default: (args...)->
        @::[iplSteps] ?= []
        @::[iplSteps].push {args, method: 'changeField'}
        return

    #@renameField #collection_name, field_name, new_field_name
    @public @async @virtual renameField: Function, # это должно быть реализовано в миксине с платформозависимым кодом
      args: [String, String, String]
      return: Module::ANY
    @public @static renameField: Function,
      args: [String, String, String]
      return: Module::NILL
      default: (args...)->
        @::[iplSteps] ?= []
        @::[iplSteps].push {args, method: 'renameField'}
        return

    #@renameIndex #collection_name, old_name, new_name
    @public @async @virtual renameIndex: Function, # это должно быть реализовано в миксине с платформозависимым кодом
      args: [String, String, String]
      return: Module::ANY
    @public @static renameIndex: Function,
      args: [String, String, String]
      return: Module::NILL
      default: (args...)->
        @::[iplSteps] ?= []
        @::[iplSteps].push {args, method: 'renameIndex'}
        return

    #@renameCollection #collection_name, old_name, new_name
    @public @async @virtual renameCollection: Function, # это должно быть реализовано в миксине с платформозависимым кодом
      args: [String, String, String]
      return: Module::ANY
    @public @static renameCollection: Function,
      args: [String, String, String]
      return: Module::NILL
      default: (args...)->
        @::[iplSteps] ?= []
        @::[iplSteps].push {args, method: 'renameCollection'}
        return

    #Deletion
    #@dropCollection #name
    @public @async @virtual dropCollection: Function, # это должно быть реализовано в миксине с платформозависимым кодом
      args: [String]
      return: Module::ANY
    @public @static dropCollection: Function,
      args: [String]
      return: Module::NILL
      default: (args...)->
        @::[iplSteps] ?= []
        @::[iplSteps].push {args, method: 'dropCollection'}
        return

    # @dropEdgeCollection #collection_1, collection_2
    @public @async @virtual dropEdgeCollection: Function, # это должно быть реализовано в миксине с платформозависимым кодом
      args: [String, String]
      return: Module::ANY
    @public @static dropEdgeCollection: Function,
      args: [String, String]
      return: Module::NILL
      default: (args...)->
        @::[iplSteps] ?= []
        @::[iplSteps].push {args, method: 'dropEdgeCollection'}
        return

    #@removeField #collection_name, field_name
    @public @async @virtual removeField: Function, # это должно быть реализовано в миксине с платформозависимым кодом
      args: [String, String]
      return: Module::ANY
    @public @static removeField: Function,
      args: [String, String]
      return: Module::NILL
      default: (args...)->
        @::[iplSteps] ?= []
        @::[iplSteps].push {args, method: 'removeField'}
        return

    #@removeIndex #collection_name, field_names, options
    @public @async @virtual removeIndex: Function, # это должно быть реализовано в миксине с платформозависимым кодом
      args: [String, Array, Object]
      return: Module::ANY
    @public @static removeIndex: Function,
      args: [String, Array, Object]
      return: Module::NILL
      default: (args...)->
        @::[iplSteps] ?= []
        @::[iplSteps].push {args, method: 'removeIndex'}
        return

    #@removeTimestamps # удаление полей createdAt, updatedAt, deletedAt #collection_name, options
    @public @async @virtual removeTimestamps: Function, # это должно быть реализовано в миксине с платформозависимым кодом
      args: [String, Object]
      return: Module::ANY
    @public @static removeTimestamps: Function,
      args: [String, Object]
      return: Module::NILL
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
        UsersCollection = @facade.retriveProxy 'UsersCollection'
        @addField 'users', 'first_name', 'string'
        @addField 'users', 'last_name', 'string'

        @reversible wrap (dir)->
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
      args: [Function]
      return: Module::NILL
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
    @public @async execute: Function, # queryFunc
      args: [Function]
      return: Module::NILL
      default: (lambda)->
        yield lambda.apply @, []
        yield return

    # управляющие методы
    #@migrate #direction - переопределять не надо, тут главная точка вызова снаружи.
    @public @async migrate: Function, # queryFunc
      args: [Function]
      return: Module::NILL
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
      args: [Function]
      return: Module::NILL
      default: (lambda)->
        lambda.apply @, []
        return

    # с кодом Collections и Records объявленных в приложении надо работать именно в `up` и в `down`
    # асинхронные, потому что будут работать с базой данных возможно через I/O
    # здесь должна быть объявлена логика "автоматическая" - если вызов `change` создает метаданные, то заиспользовать эти метаданные для выполнения. Если метаданных нет, то скорее всего либо это пока еще пустая миграция без кода вообще, либо в унаследованном классе будут переопределны и `up` и `down`
    @public @async up: Function,
      args: []
      return: Module::NILL
      default: ->
        @[iplSteps]?.forEach ({method, args})->
          if method is 'reversible'
            [lambda] = args
            yield lambda
              up: (f)-> f()
              down: -> Module::Promise.resolve()
          else
            yield @[method] args...
        yield return

    @public @static up: Function,
      args: [Function]
      return: Module::NILL
      default: (lambda)->
        @public @async up: Function,
          default: lambda
        return

    @public @async down: Function,
      args: []
      return: Module::NILL
      default: ->
        steps = @[iplSteps]?[..] ? []
        steps.reverse()
        steps.forEach ({method, args})->
          if method is 'reversible'
            [lambda] = args
            yield lambda
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
            yield @[Migration::REVERSE_MAP[methodName]] args...
        yield return

    @public @static down: Function,
      args: [Function]
      return: Module::NILL
      default: (lambda)->
        @public @async down: Function,
          default: lambda
        return

    @public init: Function,
      default: (args...)->
        @super args...
        @name ?= path.basename __filename, '.js'
        return


  Migration.initialize()