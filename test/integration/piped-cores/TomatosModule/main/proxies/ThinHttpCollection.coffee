inflect = do require 'i'


module.exports = (Module)->
  {
    Collection
    ThinHttpCollectionMixin
    # QueryableMixin
    # HttpCollectionMixin
    # IterableMixin
  } = Module::

  class ThinHttpCollection extends Collection
    @inheritProtected()
    # @include QueryableMixin
    @include ThinHttpCollectionMixin
    # @include IterableMixin
    @module Module

    @public host: String,
      get: -> @configs.cucumbersServer.host

    @public namespace: String,
      get: -> @configs.cucumbersServer.namespace

  ThinHttpCollection.initialize()
