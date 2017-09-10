

module.exports = (Module)->
  {
    Resource
    BodyParseMixin
  } = Module::

  class TomatosResource extends Resource
    @inheritProtected()
    @include BodyParseMixin
    @module Module

    # @initialHook 'checkSchemaVersion'
    @initialHook 'parseBody', only: ['create', 'update']

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
