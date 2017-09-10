

module.exports = (Module)->
  {
    Collection
    MemoryCollectionMixin
  } = Module::

  class MigrationsCollection extends Collection
    @inheritProtected()
    @include MemoryCollectionMixin
    @module Module


  MigrationsCollection.initialize()
