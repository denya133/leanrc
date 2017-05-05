

module.exports = (Module)->
  {
    Collection
    MemoryCollectionMixin
    IterableMixin
  } = Module::

  class MainCollection extends Collection
    @inheritProtected()
    @include MemoryCollectionMixin
    @include IterableMixin
    @module Module


  MainCollection.initialize()
