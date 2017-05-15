

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

    @public namespace: String,
      default: '0.1'


  ThinHttpCollection.initialize()
