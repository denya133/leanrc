

module.exports = (Module)->
  {
    Resource
    HttpCollectionMixin
    IterableMixin
  } = Module::

  class CucumbersResource extends Resource
    @inheritProtected()
    @include HttpCollectionMixin
    @include IterableMixin
    @module Module


  CucumbersResource.initialize()
