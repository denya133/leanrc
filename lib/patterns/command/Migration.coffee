# надо унаследовать от SimpleCommand
RC = require 'RC'

###
http://edgeguides.rubyonrails.org/active_record_migrations.html
http://api.rubyonrails.org/
http://guides.rubyonrails.org/v3.2/migrations.html
http://rusrails.ru/rails-database-migrations
http://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html
###



###
```coffee
module.exports = (App)->
  class App::CreateUsersCollectionMigration extends LeanRC::Migration
    @inheritProtected()
    @include ArangoExtension::ArangoMigrationMixin # в этом миксине должны быть реализованы платформозависимые методы, которые будут посылать нативные запросы к реальной базе данных

    @Module: App

    @public up: Function,
      default: ->
        @createCollection 'users'
        @addField 'users', name, 'string'
        @addField 'users', description, 'text'
        @addField 'users', createdAt, 'date'
        @addField 'users', updatedAt, 'date'
        @addField 'users', deletedAt, 'date'


    @public down: Function,
      default: ->
        @dropCollection 'users'

  return App::CreateUsersCollectionMigration.initialize()
```
###

module.exports = (LeanRC)->
  class LeanRC::Migration extends LeanRC::SimpleCommand
    @inheritProtected()
    @implements LeanRC::MigrationInterface

    @Module: LeanRC

    # так же в рамках DSL нужны:
    # Creation
    @createCollection #name, options, type # type is `document` or `edge`
    # @createEdgeCollection #для хранения связей М:М #collection_1, collection_2, options
    @addField #collection_name, field_name, options #{type}
    @addIndex #collection_name, field_names, options
    # @addReference # объявление поля для связи belongsTo # :collection_name, :reference_name
    @addTimestamps # создание полей createdAt, updatedAt, deletedAt #collection_name, options

    # Modification
    @changeCollection #name, options
    @changeField #collection_name, field_name, options #{type}
    @renameField #collection_name, field_name, new_field_name
    @renameIndex #collection_name, old_name, new_name
    @renameCollection #old_name, new_name

    #Deletion
    @dropCollection #name
    # @dropEdgeCollection #collection_1, collection_2
    @removeField #collection_name, field_name
    @removeIndex #collection_name, field_names, options
    # @removeReference # удаление поля со связью belongsTo #collection_name, ref_name, options
    @removeTimestamps # удаление полей createdAt, updatedAt, deletedAt #collection_name, options

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
      @public change: Function,
        default: ->
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
    @reversible

    # Custom
    # будет выполняться функция содержащая платформозависимый код.
    # пример использования
    ###
    ```
      {wrap} = RC::Utils.co
      @public @async up: Function,
        default: ->
          yield @execute wrap ->
            { db } = require '@arangodb'
            unless db._collection 'cucumbers'
              db._createDocumentCollection 'cucumbers', waitForSync: yes
            db._collection('cucumbers').ensureIndex
              type: 'hash'
              fields: ['_type']
            yield return
          yield return
      @public @async down: Function,
        default: ->
          yield @execute wrap ->
            { db } = require '@arangodb'
            if db._collection 'cucumbers'
              db._drop 'cucumbers'
            yield return
          yield return
    ```
    ###
    @execute # queryFunc

    # управляющие методы
    @migrate #direction - переопределять не надо, тут главная точка вызова снаружи.

    # Supported Types
    # :json
    # :binary
    # :boolean
    # :date
    # :datetime
    # :decimal
    # :float
    # :integer
    # :primary_key
    # :string
    # :text
    # :time
    # :timestamp

    # если объявлена реализация метода `change`, то `up` и `down` объявлять не нужно (будут автоматически выдавать ответ на основе методанных объявленных в `change`)
    # использовать показанные выше DSL-методы надо именно в `change`
    @public change: Function,
      default: ->

    # с кодом Collections и Records объявленных в приложении надо работать именно в `up` и в `down`
    # асинхронные, потому что будут работать с базой данных возможно через I/O
    # здесь должна быть объявлена логика "автоматическая" - если вызов `change` создает метаданные, то заиспользовать эти метаданные для выполнения. Если метаданных нет, то скорее всего либо это пока еще пустая миграция без кода вообще, либо в унаследованном классе будут переопределны и `up` и `down`
    @public @async up: Function,
      default: -> yield return

    @public @async down: Function,
      default: -> yield return


  return LeanRC::Migration.initialize()
