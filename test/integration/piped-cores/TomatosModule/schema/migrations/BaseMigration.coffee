

module.exports = (Module)->
  {
    Migration
    MemoryMigrationMixin
  } = Module::

  class BaseMigration extends Migration
    @inheritProtected()
    @module Module

    @include MemoryMigrationMixin


  BaseMigration.initialize()
