

module.exports = (Module)->
  {
    Migration
    MemoryMigrationMixin
  } = Module::

  class BaseMigration extends Migration
    @inheritProtected()
    @include MemoryMigrationMixin
    @module Module


  BaseMigration.initialize()
