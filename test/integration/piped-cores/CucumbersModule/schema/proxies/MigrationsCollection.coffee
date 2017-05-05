

module.exports = (Module)->
  {
    Collection
    MemoryCollectionMixin
  } = Module::

  class MigrationsCollection extends Collection
    @inheritProtected()
    @module Module

    @include MemoryCollectionMixin


  MigrationsCollection.initialize()
