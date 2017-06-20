

module.exports = (Module)->
  {
    Collection
    MemoryCollectionMixin
    IterableMixin
    GenerateUuidIdMixin
  } = Module::

  class MainCollection extends Collection
    @inheritProtected()
    @include MemoryCollectionMixin
    @include IterableMixin
    @include GenerateUuidIdMixin
    @module Module


  MainCollection.initialize()
