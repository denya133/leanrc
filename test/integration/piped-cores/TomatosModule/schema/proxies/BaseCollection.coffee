

module.exports = (Module)->
  {
    Collection
    MemoryCollectionMixin
  } = Module::

  class BaseCollection extends Collection
    @inheritProtected()
    @module Module

    @include MemoryCollectionMixin


  BaseCollection.initialize()
