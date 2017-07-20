

module.exports = (Module)->
  {
    Collection
    MemoryCollectionMixin
    IterableMixin
    GenerateUuidIdMixin
  } = Module::

  class BaseCollection extends Collection
    @inheritProtected()
    @include MemoryCollectionMixin
    @include IterableMixin
    @include GenerateUuidIdMixin
    @module Module


  BaseCollection.initialize()
