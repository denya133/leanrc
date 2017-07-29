

module.exports = (Module)->
  {
    Collection
    ThinHttpCollectionMixin
    GenerateUuidIdMixin
  } = Module::

  class ThinHttpCollection extends Collection
    @inheritProtected()
    @include ThinHttpCollectionMixin
    @include GenerateUuidIdMixin
    @module Module

    @public host: String,
      get: -> @configs.cucumbersServer.host

    @public namespace: String,
      get: -> @configs.cucumbersServer.namespace


  ThinHttpCollection.initialize()
