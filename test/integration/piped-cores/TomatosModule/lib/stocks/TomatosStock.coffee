

module.exports = (Module)->
  {
    Stock
  } = Module::

  class TomatosStock extends Stock
    @inheritProtected()
    @module Module

    @public entityName: String,
      default: 'tomato'

    @public keyName: String,
      get: -> 'tomato'

    @public itemEntityName: String,
      get: -> 'tomato'

    @public listEntityName: String,
      get: -> 'tomatos'

    @public collectionName: String,
      get: -> 'TomatosCollection'

    @public @async list: Function,
      default: (args...)->
        yield @super args...


  TomatosStock.initialize()
