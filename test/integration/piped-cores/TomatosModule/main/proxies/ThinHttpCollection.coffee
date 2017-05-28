

module.exports = (Module)->
  {
    Collection
    ThinHttpCollectionMixin
  } = Module::

  class ThinHttpCollection extends Collection
    @inheritProtected()
    @include ThinHttpCollectionMixin
    @module Module

    @public host: String,
      get: -> @configs.cucumbersServer.host

    @public namespace: String,
      get: -> @configs.cucumbersServer.namespace


  ThinHttpCollection.initialize()
