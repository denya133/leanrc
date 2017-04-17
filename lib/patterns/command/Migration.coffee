# надо унаследовать от SimpleCommand
RC = require 'RC'

###
http://edgeguides.rubyonrails.org/active_record_migrations.html
http://api.rubyonrails.org/
http://guides.rubyonrails.org/v3.2/migrations.html
http://rusrails.ru/rails-database-migrations
###


###
```coffee
module.exports = (App)->
  class App::BaseMigration extends LeanRC::Migration
    @inheritProtected()
    @include ArangoExtension::ArangoMigrationMixin # в этом миксине должны быть реализованы платформозависимые методы, которые будут посылать нативные запросы к реальной базе данных

    @Module: App

  return App::BaseMigration.initialize()
  ```
###

###
```coffee
module.exports = (App)->
  class App::CreateUsersCollectionMigration extends App::BaseMigration
    @inheritProtected()

    @Module: App

    @public up: Function,
      default: ->
        @createCollection 'users', (c)->
          c.string 'name'
          c.text 'description', 'text', {null: no}

          c.timestamps()


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
    @createCollection
    # @createEdgeCollection #для хранения связей М:М
    @addField
    @addIndex
    addReference # объявление поля для связи belongsTo
    @addTimestamps # создание полей createdAt, updatedAt, deletedAt

    # Modification
    @changeCollection
    @changeField
    @renameField
    @renameIndex
    @renameCollection

    #Deletion
    @dropCollection
    # @dropEdgeCollection
    @removeField
    @removeIndex
    @removeReference # удаление поля со связью belongsTo
    @removeTimestamps # удаление полей createdAt, updatedAt, deletedAt

    # Custom
    @execute

    # Supported Types
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

    @public up: Function,
      default: ->

    @public down: Function,
      default: ->


  return LeanRC::Migration.initialize()
