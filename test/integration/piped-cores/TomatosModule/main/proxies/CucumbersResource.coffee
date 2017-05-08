

module.exports = (Module)->
  {
    Resource
    QueryableMixin
    HttpCollectionMixin
    IterableMixin
  } = Module::

  class CucumbersResource extends Resource
    @inheritProtected()
    @include QueryableMixin
    @include HttpCollectionMixin
    @include IterableMixin
    @module Module


  CucumbersResource.initialize()
