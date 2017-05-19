

module.exports = (Module)->
  {
    Resource
  } = Module::

  class TomatosResource extends Resource
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

    @action @async getCucumbers: Function,
      default: ->
        cucucmbers = @facade.retrieveProxy 'CucumbersCollection'
        yield (yield cucucmbers.takeAll()).toArray()


  TomatosResource.initialize()
