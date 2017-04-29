

module.exports = (Module)->
  {
    Migration
  } = Module::

  class BaseMigration extends Migration
    @inheritProtected()
    @module Module

    @include MongoMigrationMixin


  BaseMigration.initialize()
