

module.exports = (Module)->
  {
    Resource
    HttpCollectionMixin
    IterableMixin
  } = Module::

  class BaseResource extends Resource
    @inheritProtected()
    @include HttpCollectionMixin
    @include IterableMixin
    @module Module


  BaseResource.initialize()
