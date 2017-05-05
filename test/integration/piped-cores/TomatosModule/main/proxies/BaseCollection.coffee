

module.exports = (Module)->
  {
    Collection
    MemoryCollectionMixin
    IterableMixin
  } = Module::

  class BaseCollection extends Collection
    @inheritProtected()
    @include MemoryCollectionMixin
    @include IterableMixin
    @module Module


  BaseCollection.initialize()
